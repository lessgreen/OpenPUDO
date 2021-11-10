package less.green.openpudo.rest.dto.auth;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class ConfirmResetPasswordRequest {

    @Schema(required = true)
    private String login;

    @Schema(required = true)
    private String otp;

    @Schema(required = true)
    private String newPassword;
}
