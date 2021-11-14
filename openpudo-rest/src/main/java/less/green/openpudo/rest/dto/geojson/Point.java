package less.green.openpudo.rest.dto.geojson;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class Point {

    private String type;
    private List<BigDecimal> coordinates;

}
