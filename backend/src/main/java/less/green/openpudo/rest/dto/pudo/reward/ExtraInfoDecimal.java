package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@ToString(callSuper = true)
@JsonInclude(JsonInclude.Include.ALWAYS)
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

    public ExtraInfoDecimal(String name, String text, ExtraInfoType type, Boolean mandatoryValue, BigDecimal min, BigDecimal max, Integer scale, BigDecimal step, BigDecimal value) {
        super(name, text, type, mandatoryValue);
        this.min = min;
        this.max = max;
        this.scale = scale;
        this.step = step;
        this.value = value;
    }

}
