package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.UserProfile;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema(description = "Fields 'email' and 'phoneNumber' are technically optional, but you must provide at least one of them.")
public class RegisterRequest {

    private String username;

    private String email;

    private String phoneNumber;

    @Schema(required = true)
    private String password;

    @Schema(required = true)
    private UserProfile userProfile;

}
