package less.green.openpudo.rest.dto.geojson;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import java.util.List;
import lombok.Data;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class FeatureCollection {

    private String type;
    private List<Feature> features;

}
