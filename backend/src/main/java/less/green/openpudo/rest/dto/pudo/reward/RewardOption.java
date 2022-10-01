package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@JsonInclude(JsonInclude.Include.ALWAYS)
@NoArgsConstructor
@AllArgsConstructor
@Schema
public class RewardOption {

    @Schema(required = true)
    private String name;

    @Schema(readOnly = true)
    private String text;

    @Schema(readOnly = true)
    private RewardIcon icon;

    @Schema(readOnly = true)
    private Boolean exclusive;

    @Schema(required = true)
    private Boolean checked;

    private ExtraInfo extraInfo;

    public RewardOption(String name, String text, RewardIcon icon, Boolean exclusive, Boolean checked) {
        this.name = name;
        this.text = text;
        this.icon = icon;
        this.exclusive = exclusive;
        this.checked = checked;
    }

}
