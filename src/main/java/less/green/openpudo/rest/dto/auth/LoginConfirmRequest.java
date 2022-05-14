package less.green.openpudo.rest.dto.auth;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class LoginConfirmRequest {

    @Schema(required = true)
    private String phoneNumber;

    @Schema(required = true)
    private String otp;

}
