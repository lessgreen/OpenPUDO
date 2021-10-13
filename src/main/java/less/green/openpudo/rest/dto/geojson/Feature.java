package less.green.openpudo.rest.dto.geojson;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.Map;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Feature {

    private String type;
    private Point geometry;
    private Map<String, Object> properties;

}
