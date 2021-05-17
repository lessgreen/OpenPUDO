package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.Address;
import less.green.openpudo.rest.dto.UserProfile;
import lombok.Data;

@Data
public class RegisterRequest {

    private String username;

    private String email;

    private String phoneNumber;

    private String password;

    private UserProfile userProfile;

    private Address address;

}
