package less.green.openpudo.rest.dto.map;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PudoMarker {

    private Long pudoId;

    private String businessName;

    private String label;

    private BigDecimal lat;

    private BigDecimal lon;

}
