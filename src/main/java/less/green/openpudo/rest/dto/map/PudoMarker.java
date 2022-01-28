package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.pudo.PudoSummary;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
public class PudoMarker {

    @Schema(readOnly = true)
    private PudoSummary pudo;

    @Schema(readOnly = true)
    private BigDecimal lat;

    @Schema(readOnly = true)
    private BigDecimal lon;

    @Schema(readOnly = true)
    private BigDecimal distanceFromOrigin;

}
