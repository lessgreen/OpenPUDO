package less.green.openpudo.rest.dto.address;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class AddressRequest {

    @Schema(required = true)
    private String label;

    @Schema(required = true)
    private String resultId;

}
