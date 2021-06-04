package less.green.openpudo.rest.dto.geojson;

import java.math.BigDecimal;
import java.util.List;
import lombok.Data;

@Data
public class Point {

    private String type;
    private List<BigDecimal> coordinates;

}
