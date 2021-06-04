package less.green.openpudo.rest.dto.geojson;

import java.util.Map;
import lombok.Data;

@Data
public class Feature {

    private String type;
    private Point geometry;
    private Map<String, String> properties;

}
