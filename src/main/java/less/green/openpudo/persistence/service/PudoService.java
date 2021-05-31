package less.green.openpudo.persistence.service;

import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.isEmpty;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.persistence.dao.PudoDao;
import less.green.openpudo.persistence.dao.PudoUserRoleDao;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.rest.dto.pudo.Pudo;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class PudoService {

    @Inject
    PudoDao pudoDao;
    @Inject
    PudoUserRoleDao pudoUserRoleDao;

    public PudoAndAddress getPudoAndAddressById(Long pudoId) {
        return pudoDao.getPudoAndAddressById(pudoId);
    }

    public Long getPudoIdByOwnerUserId(Long userId) {
        return pudoDao.getPudoIdByOwnerUserId(userId);
    }

    public PudoAndAddress getPudoAndAddressByOwnerUserId(Long userId) {
        return pudoDao.getPudoAndAddressByOwnerUserId(userId);
    }

    public PudoAndAddress updatePudoByOwnerUserId(Long userId, Pudo req) {
        Date now = new Date();
        PudoAndAddress ret = getPudoAndAddressByOwnerUserId(userId);
        TbPudo pudo = ret.getPudo();
        pudo.setUpdateTms(now);
        pudo.setBusinessName(sanitizeString(req.getBusinessName()));
        pudo.setVat(sanitizeString(req.getVat()));
        pudo.setPhoneNumber(req.getPhoneNumber());
        pudo.setContactNotes(req.getContactNotes());
        pudoDao.flush();
        return ret;
    }

    public List<PudoAndAddress> searchPudo(BigDecimal lat, BigDecimal lon, Integer zoom, String businessName) {
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
            // should never happen, data is sanitized in service layer
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

        // tokenizing search string
        List<String> tokens = isEmpty(businessName) ? null : Arrays.asList(businessName.split("\\s"));
        return pudoDao.searchPudo(latMin, latMax, lonMin, lonMax, tokens);
    }

}
