package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.GooglePlacesSessionDao;
import less.green.openpudo.business.dao.PudoDao;
import less.green.openpudo.business.model.TbGooglePlacesSession;
import less.green.openpudo.business.model.TbRating;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.GooglePlacesService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.tuple.Septet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.GPSMarker;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.util.*;

import static less.green.openpudo.common.GPSUtils.calculateDistanceFromOrigin;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class MapService {

    private static final int MIN_PUDO_COUNT_FOR_ZOOM_LEVEL = 3;
    private static final int MAX_PUDO_MARKER_COUNT_ON_MAP = 25;
    private static final int MAX_SEARCH_RESULTS = 5;

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    GooglePlacesService googlePlacesService;

    @Inject
    GooglePlacesSessionDao googlePlacesSessionDao;
    @Inject
    PudoDao pudoDao;

    @Inject
    DtoMapper dtoMapper;

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

        List<Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal>> rs = pudoDao.getPudosOnMap(latMin, latMax, lonMin, lonMax);
        List<PudoMarker> ret = new ArrayList<>(rs.size());
        for (var row : rs) {
            PudoSummary pudo = dtoMapper.mapPudoSummaryDto(row.getValue0(), row.getValue1(), row.getValue2(), row.getValue3(), row.getValue4(), null);
            BigDecimal distanceFromOrigin = calculateDistanceFromOrigin(row.getValue5(), row.getValue6(), lat, lon);
            PudoMarker marker = dtoMapper.mapPudoMarkerDto(pudo, row.getValue5(), row.getValue6(), distanceFromOrigin);
            ret.add(marker);
        }
        // ordering by distance
        if (ret.size() > 1) {
            ret.sort(Comparator.comparingDouble(i -> i.getDistanceFromOrigin().doubleValue()));
        }
        // restricting results if necessary
        if (ret.size() > MAX_PUDO_MARKER_COUNT_ON_MAP) {
            ret = ret.subList(0, MAX_PUDO_MARKER_COUNT_ON_MAP);
        }
        return ret;
    }

    public List<AddressMarker> searchAddress(String text, BigDecimal lat, BigDecimal lon) {
        // prevent returning meaningless results with too few characters
        if (text.trim().length() <= 3) {
            return Collections.emptyList();
        }
        try {
            TbGooglePlacesSession googlePlacesSession;
            if (context.getUserId() != null) {
                googlePlacesSession = googlePlacesSessionDao.getSessionByUserId(context.getUserId());
            } else {
                googlePlacesSession = googlePlacesSessionDao.getSessionByPhoneNumber(context.getPrivateClaims().getPhoneNumber());
            }

            UUID sessionId;
            Date now = new Date();
            if (googlePlacesSession == null) {
                sessionId = UUID.randomUUID();
                googlePlacesSession = new TbGooglePlacesSession();
                googlePlacesSession.setSessionId(sessionId);
                googlePlacesSession.setCreateTms(now);
                googlePlacesSession.setUpdateTms(now);
                if (context.getUserId() != null) {
                    googlePlacesSession.setUserId(context.getUserId());
                } else {
                    googlePlacesSession.setPhoneNumber(context.getPrivateClaims().getPhoneNumber());
                }
                googlePlacesSessionDao.persist(googlePlacesSession);
            } else {
                sessionId = googlePlacesSession.getSessionId();
                googlePlacesSession.setUpdateTms(now);
            }

            return googlePlacesService.autocomplete(sessionId, context.getLanguage(), text, lat, lon);
        } catch (RuntimeException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }
    }

    public AddressMarker getAddressDetails(String signature, BigDecimal lat, BigDecimal lon) {
        try {
            TbGooglePlacesSession googlePlacesSession;
            if (context.getUserId() != null) {
                googlePlacesSession = googlePlacesSessionDao.getSessionByUserId(context.getUserId());
            } else {
                googlePlacesSession = googlePlacesSessionDao.getSessionByPhoneNumber(context.getPrivateClaims().getPhoneNumber());
            }

            UUID sessionId;
            if (googlePlacesSession != null) {
                sessionId = googlePlacesSession.getSessionId();
                googlePlacesSessionDao.remove(googlePlacesSession);
            } else {
                sessionId = UUID.randomUUID();
            }

            return googlePlacesService.getAddressDetails(sessionId, context.getLanguage(), signature, lat, lon);
        } catch (RuntimeException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }
    }

    public List<PudoMarker> searchPudo(String text, BigDecimal lat, BigDecimal lon) {
        // prevent returning meaningless results with too few characters, and removing characters that can interfere with full text search
        if (text.trim().replaceAll("[*&:|()]", "").length() <= 3) {
            return Collections.emptyList();
        }
        // tokenizing search string
        List<String> tokens = Arrays.asList(text.trim().split("\\s+"));
        List<Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal>> rs = pudoDao.searchPudo(tokens);
        List<PudoMarker> ret = new ArrayList<>(rs.size());
        for (var row : rs) {
            PudoSummary pudo = dtoMapper.mapPudoSummaryDto(row.getValue0(), row.getValue1(), row.getValue2(), row.getValue3(), row.getValue4(), null);
            BigDecimal distanceFromOrigin = lat != null && lon != null ? calculateDistanceFromOrigin(row.getValue5(), row.getValue6(), lat, lon) : null;
            PudoMarker marker = dtoMapper.mapPudoMarkerDto(pudo, row.getValue5(), row.getValue6(), distanceFromOrigin);
            ret.add(marker);
        }
        // ordering by distance
        if (ret.size() > 1 && lat != null && lon != null) {
            ret.sort(Comparator.comparingDouble(i -> i.getDistanceFromOrigin().doubleValue()));
        }
        // restricting results if necessary
        if (ret.size() > MAX_SEARCH_RESULTS) {
            ret = ret.subList(0, MAX_SEARCH_RESULTS);
        }
        return ret;
    }

    public List<GPSMarker> searchGlobal(String text, BigDecimal lat, BigDecimal lon) {
        List<AddressMarker> rs1 = searchAddress(text, lat, lon);
        List<PudoMarker> rs2 = searchPudo(text, lat, lon);
        List<GPSMarker> ret = new ArrayList<>(rs1.size() + rs2.size());
        ret.addAll(rs1);
        ret.addAll(rs2);
        return ret;
    }

}
