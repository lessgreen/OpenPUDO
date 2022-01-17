package less.green.openpudo.rest.dto.pudo;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;

@Data
public class Rating {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private Long reviewCount;

    @Schema(readOnly = true)
    private BigDecimal averageScore;

}
