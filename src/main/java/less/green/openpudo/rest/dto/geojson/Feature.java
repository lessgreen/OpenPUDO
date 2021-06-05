package less.green.openpudo.rest.dto.geojson;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.Map;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Feature {

    private String type;
    private Point geometry;
    private Map<String, Object> properties;

}
