package less.green.openpudo.rest.dto.pack;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema
public class ChangePackageStatusRequest {

    private String notes;

}
