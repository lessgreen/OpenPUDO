package less.green.openpudo.rest.dto.pack;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Data
public class DeliveredPackageRequest {

    @Schema(required = true)
    private Long userId;

    private UUID packagePicId;

    private String notes;

}
