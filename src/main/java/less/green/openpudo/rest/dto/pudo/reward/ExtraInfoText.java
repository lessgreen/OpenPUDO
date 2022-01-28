package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@ToString(callSuper = true)
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ExtraInfoText extends ExtraInfo {

    @Schema(required = true)
    private String value;

}
