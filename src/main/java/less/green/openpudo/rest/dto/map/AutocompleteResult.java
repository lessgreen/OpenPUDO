package less.green.openpudo.rest.dto.map;

import java.math.BigDecimal;
import lombok.Data;

@Data
public class AutocompleteResult {

    private String label;

    private String resultId;

    private BigDecimal lat;

    private BigDecimal lon;

}
