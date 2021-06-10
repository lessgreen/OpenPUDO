package less.green.openpudo.rest.dto.map;

import java.math.BigDecimal;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddressMarker {

    private String resultId;

    private String label;

    private String precision;

    private BigDecimal lat;

    private BigDecimal lon;

}
