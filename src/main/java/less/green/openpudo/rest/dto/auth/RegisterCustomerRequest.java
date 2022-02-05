package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.user.User;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class RegisterCustomerRequest {

    @Schema(required = true)
    private User user;

}
