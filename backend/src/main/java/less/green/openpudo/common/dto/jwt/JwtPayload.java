package less.green.openpudo.common.dto.jwt;

import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@NoArgsConstructor
public class JwtPayload {

    // issuer of JWT
    private String iss;

    // subject, primary key of user
    private Long sub;

    // issued at
    private Instant iat;

    // expire date
    private Instant exp;

    // private claims specific to our application, those claims are not collision resistant and are not intended for interoperability
    private JwtPrivateClaims privateClaims;

    public JwtPayload(Long sub, Instant iat, Instant exp, JwtPrivateClaims privateClaims) {
        this.iss = "OpenPUDO";
        this.sub = sub;
        this.iat = iat;
        this.exp = exp;
        this.privateClaims = privateClaims;
    }

}
