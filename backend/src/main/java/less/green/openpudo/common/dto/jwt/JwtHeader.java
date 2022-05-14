package less.green.openpudo.common.dto.jwt;

import lombok.Data;

@Data
public class JwtHeader {

    private final String alg = "HS512";
    private final String typ = "JWT";

}
