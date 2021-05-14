package less.green.openpudo.rest.dto.auth;

import lombok.Data;

@Data
public class RegisterRequest {

    private String username;
    private String email;
    private String phoneNumber;
    private String password;

}
