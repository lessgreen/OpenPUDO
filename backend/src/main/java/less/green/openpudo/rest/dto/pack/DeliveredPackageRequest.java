package less.green.openpudo.rest.dto.pack;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema
public class DeliveredPackageRequest {

    @Schema(required = true)
    private Long userId;

    private String notes;

}
