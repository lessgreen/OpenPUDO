package less.green.openpudo.rest.dto.pudo.reward;

import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
@ToString(callSuper = true)
public class ExtraInfoDecimal extends ExtraInfo {

    @Schema(readOnly = true)
    private BigDecimal min;

    @Schema(readOnly = true)
    private BigDecimal max;

    @Schema(readOnly = true)
    private Integer scale;

    @Schema(readOnly = true)
    private BigDecimal step;

    @Schema(required = true)
    private BigDecimal value;

}
