package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@NoArgsConstructor
@ToString(callSuper = true)
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ExtraInfoText extends ExtraInfo {

    @Schema(required = true)
    private String value;

    public ExtraInfoText(String name, String text, ExtraInfoType type, Boolean mandatoryValue, String value) {
        super(name, text, type, mandatoryValue);
        this.value = value;
    }

}
