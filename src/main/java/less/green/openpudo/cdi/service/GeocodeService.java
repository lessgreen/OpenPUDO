package less.green.openpudo.cdi.service;

import io.quarkus.runtime.Startup;
import kong.unirest.Unirest;
import kong.unirest.UnirestException;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.geojson.FeatureCollection;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

import static less.green.openpudo.common.StringUtils.isEmpty;

@ApplicationScoped
@Startup
@Log4j2
public class GeocodeService {

    private static final String GEOCODE_API_URL = "https://api.geocode.earth/v1";
    private static final String GEOCODE_AUTOCOMPLETE_URL = GEOCODE_API_URL + "/autocomplete";

    @ConfigProperty(name = "geocode.api.key")
    String apiKey;

    public FeatureCollection autocomplete(String language, String text, BigDecimal lat, BigDecimal lon) {
        try {
            var req = Unirest.get(GEOCODE_AUTOCOMPLETE_URL);
            req.queryString("api_key", apiKey);
            req.queryString("text", text);
            if (lat != null && lon != null) {
                req.queryString("focus.point.lat", lat.toString());
                req.queryString("focus.point.lon", lon.toString());
            }

            // heuristic to filter too grainy results
            List<String> tokens = Arrays.asList(text.trim().split("\\s"));
            boolean containNumber = tokens.stream().anyMatch(i -> i.matches("\\d+.*"));
            if (tokens.size() > 1 && containNumber) {
                req.queryString("layers", "address,street,borough,locality,localadmin,county,macrocounty,region,macroregion,country");
            } else {
                req.queryString("layers", "street,borough,locality,localadmin,county,macrocounty,region,macroregion,country");
            }

            if (!isEmpty(language)) {
                req.header("Accept-Language", language);
            } else {
                req.header("Accept-Language", "en");
            }

            var res = req.asObject(FeatureCollection.class);
            if (res == null || res.getBody() == null) {
                throw new RuntimeException("Geocode service returned empty response");
            }
            if (res.getStatus() != 200) {
                throw new RuntimeException("Geocode service returned: " + res.getStatus() + " " + res.getStatusText());
            }

            FeatureCollection rs = res.getBody();
            List<Feature> filtered = rs.getFeatures().stream()
                    .filter(i -> i.getProperties() != null && i.getGeometry() != null && i.getGeometry().getCoordinates() != null && i.getGeometry().getCoordinates().size() >= 2)
                    .collect(Collectors.toList());
            rs.setFeatures(filtered);
            return rs;
        } catch (UnirestException ex) {
            throw new RuntimeException("Geocode service unavailable", ex);
        }
    }

}
