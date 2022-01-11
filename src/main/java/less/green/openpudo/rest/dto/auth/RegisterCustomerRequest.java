package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.user.UserProfile;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class RegisterCustomerRequest {

    @Schema(required = true)
    private UserProfile userProfile;

}
