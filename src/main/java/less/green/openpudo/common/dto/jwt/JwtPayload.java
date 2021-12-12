package less.green.openpudo.common.dto.jwt;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.util.Date;

@Data
public class JwtPayload {

    // issuer of JWT
    private final String iss = "OpenPUDO";

    // subject, primary key of user
    private final Long sub;

    // issued at
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private final Date iat;

    // expire date
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private final Date exp;

    // private claims specific to our application, those claims are not collision resistant and are not intended for interoperability
    private final JwtPrivateClaims privateClaims;

}
