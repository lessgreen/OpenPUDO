package less.green.openpudo.rest.dto.map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

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
