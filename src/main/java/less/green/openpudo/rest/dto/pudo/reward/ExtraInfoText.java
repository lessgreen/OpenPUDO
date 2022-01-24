package less.green.openpudo.rest.dto.pudo.reward;

import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@ToString(callSuper = true)
public class ExtraInfoText extends ExtraInfo {

    @Schema(required = true)
    private String value;

}
