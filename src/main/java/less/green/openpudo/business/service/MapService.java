package less.green.openpudo.business.service;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.GeocodeService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.FeatureCollection;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.SignedAddressMarker;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import java.math.BigDecimal;
import java.util.ArrayList;
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

}
