package less.green.openpudo.common.dto.jwt;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.AllArgsConstructor;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;

@Data
@AllArgsConstructor
@Schema
public class AccessTokenData {

    private String accessToken;

    private AccessProfile accessProfile;

    // additional fields already in the access token, for easier access by client
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant issueDate;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant expireDate;

}
