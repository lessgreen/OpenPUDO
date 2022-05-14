package less.green.openpudo.common.dto.jwt;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JwtPrivateClaims {

    private String phoneNumber;

}
