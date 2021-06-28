package less.green.openpudo.cdi.service;

import java.math.BigDecimal;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.ApplicationScoped;
import kong.unirest.GetRequest;
import kong.unirest.HttpResponse;
import kong.unirest.Unirest;
import kong.unirest.UnirestException;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.geojson.FeatureCollection;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
@Log4j2
public class GeocodeService {

    @ConfigProperty(name = "geocode.api.key")
    String apiKey;

    @ConfigProperty(name = "geocode.api.url")
    String apiUrl;

    static {
        Unirest.config().reset();
        Unirest.config()
                .socketTimeout(5000)
                .connectTimeout(5000);
    }

    public FeatureCollection autocomplete(String text, BigDecimal lat, BigDecimal lon) {
        try {
            GetRequest req = Unirest.get(apiUrl + "/autocomplete");
            req.queryString("api_key", apiKey);
            req.queryString("text", text);
            if (lat != null && lon != null) {
                req.queryString("focus.point.lat", lat.toString());
                req.queryString("focus.point.lon", lon.toString());
            }

            // heuristic to filter too grainiy results
            List<String> tokens = Arrays.asList(text.trim().split("\\s"));
            boolean containNumber = tokens.stream().filter(i -> i.matches("\\d+.*")).findFirst().isPresent();
            if (tokens.size() > 1 && containNumber) {
                req.queryString("layers", "address,street,borough,locality,localadmin,county,macrocounty,region,macroregion,country");
            } else {
                req.queryString("layers", "street,borough,locality,localadmin,county,macrocounty,region,macroregion,country");
            }

            // TBD: proper language selection
            req.header("Accept-Language", "it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3");

            HttpResponse<FeatureCollection> res = req.asObject(FeatureCollection.class);
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

    public Feature search(String text, String resultId) {
        try {
            GetRequest req = Unirest.get(apiUrl + "/search");
            req.queryString("api_key", apiKey);
            req.queryString("text", text);

            // this function is meant to validate previously autocompleted feature
            // we need to assure that geocoding is done at most precise level before saving on database
            req.queryString("layers", "address");

            // TBD: proper language selection
            req.header("Accept-Language", "it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3");

            HttpResponse<FeatureCollection> res = req.asObject(FeatureCollection.class);
            if (res == null || res.getBody() == null) {
                throw new RuntimeException("Geocode service returned empty response");
            }
            if (res.getStatus() != 200) {
                throw new RuntimeException("Geocode service returned: " + res.getStatus() + " " + res.getStatusText());
            }

            FeatureCollection rs = res.getBody();
            if (rs.getFeatures() == null || rs.getFeatures().isEmpty()) {
                throw new RuntimeException("Geocode service was unable to localize address");
            }

            Feature feat = rs.getFeatures().stream()
                    .filter(i -> i.getProperties() != null && i.getGeometry() != null && i.getGeometry().getCoordinates() != null && i.getGeometry().getCoordinates().size() >= 2)
                    .filter(i -> resultId.equals((String) i.getProperties().get("gid")))
                    .findFirst().orElse(null);
            return feat;
        } catch (UnirestException ex) {
            throw new RuntimeException("Geocode service unavailable", ex);
        }
    }

}
