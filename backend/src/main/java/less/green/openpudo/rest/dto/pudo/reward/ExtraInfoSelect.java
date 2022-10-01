package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;

@Data
@ToString(callSuper = true)
@NoArgsConstructor
@Schema
@JsonInclude(JsonInclude.Include.ALWAYS)
public class ExtraInfoSelect extends ExtraInfo {

    @Schema(readOnly = true)
    private List<ExtraInfoSelectItem> values;

    public ExtraInfoSelect(String name, String text, ExtraInfoType type, Boolean mandatoryValue, List<ExtraInfoSelectItem> values) {
        super(name, text, type, mandatoryValue);
        this.values = values;
    }

}
