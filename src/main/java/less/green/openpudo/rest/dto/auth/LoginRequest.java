package less.green.openpudo.rest.dto.auth;

import lombok.Data;

@Data
public class LoginRequest {

    private String login;
    private String password;

}
