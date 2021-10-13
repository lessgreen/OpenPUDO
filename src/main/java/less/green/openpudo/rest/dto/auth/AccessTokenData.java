package less.green.openpudo.rest.dto.auth;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.Date;

@Data
@AllArgsConstructor
public class AccessTokenData {

    private String accessToken;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date issueDate;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date expireDate;

}
