package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.PudoDao;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.GeocodeService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.GPSUtils;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.FeatureCollection;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.map.SignedAddressMarker;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@RequestScoped
@Log4j2
public class MapService {

    private static final int MIN_PUDO_COUNT_FOR_ZOOM_LEVEL = 5;
    private static final int MAX_PUDO_MARKER_COUNT_ON_MAP = 25;
    private static final int MAX_SEARCH_RESULTS = 5;

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    CryptoService cryptoService;
    @Inject
    GeocodeService geocodeService;

    @Inject
    PudoDao pudoDao;

    @Inject
    DtoMapper dtoMapper;

    public List<SignedAddressMarker> searchAddress(String text, BigDecimal lat, BigDecimal lon) {
        try {
            FeatureCollection fc = geocodeService.autocomplete(context.getLanguage(), text, lat, lon);
            List<Feature> rs = fc.getFeatures();
            // restricting results if necessary (unlikely)
            if (rs.size() > MAX_SEARCH_RESULTS) {
                rs = rs.subList(0, MAX_SEARCH_RESULTS);
            }
            List<SignedAddressMarker> ret = new ArrayList<>(rs.size());
            for (Feature feat : rs) {
                AddressMarker address = dtoMapper.mapFeatureToAddressMarker(feat, lat, lon);
                String signature = cryptoService.signObject(address);
                ret.add(new SignedAddressMarker(address, signature));
            }
            return ret;
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }
    }

    @Transactional(Transactional.TxType.REQUIRED)
    public Integer getSuggestedZoom(BigDecimal lat, BigDecimal lon) {
        // try zoom level from 16 (narrower) to 9 (wider) until we get enough pudos on the map
        for (int zoom = 16; zoom > 8; zoom--) {
            List<PudoMarker> rs = getPudosOnMap(lat, lon, zoom);
            if (rs.size() >= MIN_PUDO_COUNT_FOR_ZOOM_LEVEL) {
                return zoom;
            }
        }
        // if still not enough, cap to 8
        return 8;
    }

    @Transactional(Transactional.TxType.REQUIRED)
    public List<PudoMarker> getPudosOnMap(BigDecimal lat, BigDecimal lon, Integer zoom) {
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
            // should never happen, input is sanitized in rest layer
            throw new AssertionError("Unsupported zoom level: " + zoom);
        }
        // apply some tolerance to the map borders
        MathContext mc = new MathContext(7, RoundingMode.HALF_UP);
        BigDecimal correctedDeltaDegree = deltaDegree.divide(BigDecimal.valueOf(1.75), mc);

        // map boundaries
        BigDecimal latMin = lat.subtract(correctedDeltaDegree);
        BigDecimal latMax = lat.add(correctedDeltaDegree);
        BigDecimal lonMin = lon.subtract(correctedDeltaDegree);
        BigDecimal lonMax = lon.add(correctedDeltaDegree);

        List<PudoMarker> rs = pudoDao.getPudosOnMap(latMin, latMax, lonMin, lonMax);
        if (!rs.isEmpty()) {
            for (PudoMarker pudo : rs) {
                pudo.setDistanceFromOrigin(GPSUtils.calculateDistanceFromOrigin(pudo.getLat(), pudo.getLon(), lat, lon));
            }
            // ordering by distance
            if (rs.size() > 1) {
                rs.sort(Comparator.comparingDouble(i -> i.getDistanceFromOrigin().doubleValue()));
            }
            // restricting results if necessary (unlikely)
            if (rs.size() > MAX_PUDO_MARKER_COUNT_ON_MAP) {
                rs = rs.subList(0, MAX_PUDO_MARKER_COUNT_ON_MAP);
            }
        }
        return rs;
    }
}
