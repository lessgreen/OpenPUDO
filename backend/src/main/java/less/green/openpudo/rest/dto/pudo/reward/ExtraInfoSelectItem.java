package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ExtraInfoSelectItem {

    @Schema(required = true)
    private String name;

    @Schema(readOnly = true)
    private String text;

    @Schema(required = true)
    private Boolean checked;

    private ExtraInfo extraInfo;

    public ExtraInfoSelectItem(String name, String text, Boolean checked) {
        this.name = name;
        this.text = text;
        this.checked = checked;
    }

}
