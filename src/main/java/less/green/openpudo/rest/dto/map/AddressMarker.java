package less.green.openpudo.rest.dto.map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddressMarker {

    @Schema(required = true)
    private AddressSearchResult address;

    @Schema(required = true)
    private String signature;

    @Schema(readOnly = true)
    private BigDecimal distanceFromOrigin;

}
