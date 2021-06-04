package less.green.openpudo.persistence.service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.Date;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.GeocodeService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.persistence.dao.AddressDao;
import less.green.openpudo.persistence.dao.PudoDao;
import less.green.openpudo.persistence.dao.RelationDao;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbPudoAddress;
import less.green.openpudo.persistence.model.TbPudoUserRole;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.pudo.Pudo;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class PudoService {

    @Inject
    PudoDao pudoDao;
    @Inject
    AddressDao addressDao;
    @Inject
    RelationDao relationDao;

    @Inject
    GeocodeService geocodeService;
    @Inject
    DtoMapper dtoMapper;

    public PudoAndAddress getPudoById(Long pudoId) {
        return pudoDao.getPudoById(pudoId);
    }

    public PudoAndAddress getPudoByOwner(Long userId) {
        return pudoDao.getPudoByOwner(userId);
    }

    public PudoAndAddress updatePudoByOwner(Long userId, Pudo req) {
        Date now = new Date();
        PudoAndAddress ret = getPudoByOwner(userId);
        TbPudo pudo = ret.getPudo();
        pudo.setUpdateTms(now);
        pudo.setBusinessName(sanitizeString(req.getBusinessName()));
        pudo.setVat(sanitizeString(req.getVat()));
        pudo.setPhoneNumber(req.getPhoneNumber());
        pudo.setContactNotes(req.getContactNotes());
        pudoDao.flush();
        return ret;
    }

    public PudoAndAddress updatePudoAddressByOwner(Long userId, Feature feat) {
        Date now = new Date();
        PudoAndAddress ret = getPudoByOwner(userId);
        TbAddress address = ret.getAddress();
        if (address == null) {
            address = new TbAddress();
            address.setCreateTms(now);
            address.setUpdateTms(now);
            dtoMapper.mapFeatureToExistingAddressEntity(feat, address);
            addressDao.persist(address);
            addressDao.flush();
            TbPudoAddress rel = new TbPudoAddress();
            rel.setPudoId(ret.getPudo().getPudoId());
            rel.setAddressId(address.getAddressId());
            relationDao.persist(rel);
            relationDao.flush();
            ret.setAddress(address);
        } else {
            address.setUpdateTms(now);
            dtoMapper.mapFeatureToExistingAddressEntity(feat, address);
            addressDao.flush();
        }
        return ret;
    }

    public boolean isPudoOwner(Long userId) {
        return relationDao.isPudoOwner(userId);
    }

    public boolean isPudoCustomer(Long userId, Long pudoId) {
        return relationDao.isPudoCustomer(userId, pudoId);
    }

    public List<PudoAndAddress> getPudoListByCustomer(Long userId) {
        return pudoDao.getPudoListByCustomer(userId);
    }

    public List<PudoAndAddress> addPudoToFavourites(Long userId, Long pudoId) {
        TbPudoUserRole rel = new TbPudoUserRole();
        rel.setUserId(userId);
        rel.setPudoId(pudoId);
        rel.setCreateTms(new Date());
        rel.setRoleType(RoleType.CUSTOMER);
        relationDao.persist(rel);
        relationDao.flush();
        return getPudoListByCustomer(userId);
    }

    public List<PudoAndAddress> removePudoFromFavourites(Long userId, Long pudoId) {
        relationDao.removePudoFromFavourites(userId, pudoId);
        return getPudoListByCustomer(userId);
    }

    public List<PudoAndAddress> searchPudo(BigDecimal lat, BigDecimal lon, Integer zoom) {
        // calculate map boundaries based on zoom levels, between 8 and 16, according to https://wiki.openstreetmap.org/wiki/Zoom_levels
        BigDecimal deltaDegree;
        if (zoom == 8) {
            deltaDegree = BigDecimal.valueOf(1.406);
        } else if (zoom == 9) {
            deltaDegree = BigDecimal.valueOf(0.703);
        } else if (zoom == 10) {
            deltaDegree = BigDecimal.valueOf(0.352);
        } else if (zoom == 11) {
            deltaDegree = BigDecimal.valueOf(0.176);
        } else if (zoom == 12) {
            deltaDegree = BigDecimal.valueOf(0.088);
        } else if (zoom == 13) {
            deltaDegree = BigDecimal.valueOf(0.044);
        } else if (zoom == 14) {
            deltaDegree = BigDecimal.valueOf(0.022);
        } else if (zoom == 15) {
            deltaDegree = BigDecimal.valueOf(0.011);
        } else if (zoom == 16) {
            deltaDegree = BigDecimal.valueOf(0.005);
        } else {
            // should never happen, data is sanitized in rest layer
            throw new IllegalArgumentException("Illegal zoom level: " + zoom);
        }
        // apply some tolerance to the map borders
        MathContext mc = new MathContext(7, RoundingMode.HALF_UP);
        BigDecimal correctedDeltaDegree = deltaDegree.divide(BigDecimal.valueOf(1.75), mc);

        // map boundaries
        BigDecimal latMin = lat.subtract(correctedDeltaDegree);
        BigDecimal latMax = lat.add(correctedDeltaDegree);
        BigDecimal lonMin = lon.subtract(correctedDeltaDegree);
        BigDecimal lonMax = lon.add(correctedDeltaDegree);

        return pudoDao.searchPudo(latMin, latMax, lonMin, lonMax);
    }

}
