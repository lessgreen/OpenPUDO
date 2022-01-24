package less.green.openpudo.rest.dto.pudo.reward;

import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;

@Data
@ToString(callSuper = true)
public class ExtraInfoSelect extends ExtraInfo {

    @Schema(readOnly = true)
    private List<ExtraInfoSelectItem> selectItems;

    @Schema(required = true)
    private ExtraInfoSelectItem value;

}
