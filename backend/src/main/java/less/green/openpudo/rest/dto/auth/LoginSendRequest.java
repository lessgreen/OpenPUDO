package less.green.openpudo.rest.dto.auth;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema
public class LoginSendRequest {

    @Schema(required = true)
    private String phoneNumber;

}
