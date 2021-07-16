package less.green.openpudo.rest.dto.map.pack;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class PackageRequest {

    @Schema(required = true)
    private Long userId;

    private String notes;

}
