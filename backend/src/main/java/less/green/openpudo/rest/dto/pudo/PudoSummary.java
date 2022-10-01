package less.green.openpudo.rest.dto.pudo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema
public class PudoSummary {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private String businessName;

    @Schema(readOnly = true)
    private UUID pudoPicId;

    @Schema(readOnly = true)
    private String label;

    @Schema(readOnly = true)
    private Rating rating;

    @Schema(readOnly = true)
    private String customizedAddress;

}
