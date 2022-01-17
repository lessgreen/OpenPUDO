package less.green.openpudo.rest.dto.map;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class PudoMarker {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private BigDecimal lat;

    @Schema(readOnly = true)
    private BigDecimal lon;

    @Schema(readOnly = true)
    private BigDecimal distanceFromOrigin;

    public PudoMarker(Long pudoId, BigDecimal lat, BigDecimal lon) {
        this.pudoId = pudoId;
        this.lat = lat;
        this.lon = lon;
    }

}
