package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ExtraInfoSelectItem {

    @Schema(required = true)
    private String name;

    @Schema(readOnly = true)
    private String text;

    private ExtraInfo extraInfo;

}
