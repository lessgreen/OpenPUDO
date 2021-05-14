package less.green.openpudo.common.dto;

import lombok.Data;

@Data
public class UserSecret {

    private final String saltBase64;
    private final String passwordHashBase64;
    private final String hashSpecs;

}
