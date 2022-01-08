package less.green.openpudo.common.dto.geojson;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class FeatureCollection {

    private String type;
    private List<Feature> features;

}
