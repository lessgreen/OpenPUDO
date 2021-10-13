package less.green.openpudo.rest.dto.map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

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
