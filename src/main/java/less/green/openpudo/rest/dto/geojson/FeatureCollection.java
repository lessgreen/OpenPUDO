package less.green.openpudo.rest.dto.geojson;

import java.util.List;
import lombok.Data;

@Data
public class FeatureCollection {

    private String type;
    private List<Feature> features;

}
