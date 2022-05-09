package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.pudo.PudoSummary;
import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@ToString(callSuper = true)
public class PudoMarker extends GPSMarker {

    @Schema(readOnly = true)
    private PudoSummary pudo;

}
