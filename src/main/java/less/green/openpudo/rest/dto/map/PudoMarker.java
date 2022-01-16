package less.green.openpudo.rest.dto.map;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
public class PudoMarker {

    private Long pudoId;

    private String businessName;

    private BigDecimal lat;

    private BigDecimal lon;

    private BigDecimal distanceFromOrigin;

    public PudoMarker(Long pudoId, String businessName, BigDecimal lat, BigDecimal lon) {
        this.pudoId = pudoId;
        this.businessName = businessName;
        this.lat = lat;
        this.lon = lon;
    }

}
