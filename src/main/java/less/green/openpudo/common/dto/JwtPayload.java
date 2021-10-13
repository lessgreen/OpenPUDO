package less.green.openpudo.common.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Date;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class JwtPayload {

    // issuer of JWT
    private String iss;
    //Subject, primary key of user
    private Long sub;
    // issued at
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date iat;
    // expire date
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date exp;

}
