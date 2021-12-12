package less.green.openpudo.rest.dto.auth;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class LoginSendRequest {

    @Schema(required = true)
    private String phoneNumber;

}
