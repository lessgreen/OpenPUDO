package less.green.openpudo.rest.dto.map;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
@Schema(oneOf = {AddressMarker.class, PudoMarker.class})
public class GPSMarker {

    @Schema(readOnly = true)
    private BigDecimal lat;

    @Schema(readOnly = true)
    private BigDecimal lon;

    @Schema(readOnly = true)
    private BigDecimal distanceFromOrigin;

    private String signature;

}
