package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.user.User;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class RegisterRequest {

    private String username;

    private String email;

    private String phoneNumber;

    @Schema(required = true)
    private String password;

    @Schema(required = true)
    private User user;

    private Pudo pudo;

}
