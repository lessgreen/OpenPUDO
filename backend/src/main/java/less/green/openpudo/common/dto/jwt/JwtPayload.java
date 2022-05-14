package less.green.openpudo.common.dto.jwt;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
public class JwtPayload {

    // issuer of JWT
    private String iss;

    // subject, primary key of user
    private Long sub;

    // issued at
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date iat;

    // expire date
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date exp;

    // private claims specific to our application, those claims are not collision resistant and are not intended for interoperability
    private JwtPrivateClaims privateClaims;

    public JwtPayload(Long sub, Date iat, Date exp, JwtPrivateClaims privateClaims) {
        this.iss = "OpenPUDO";
        this.sub = sub;
        this.iat = iat;
        this.exp = exp;
        this.privateClaims = privateClaims;
    }
}
