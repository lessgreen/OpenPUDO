package less.green.openpudo.rest.dto.user;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.io.Serializable;
import java.time.Instant;

@Data
@Schema
public class UserPreferences implements Serializable {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private Instant createTms;

    @Schema(readOnly = true)
    private Instant updateTms;

    @Schema(required = true)
    private Boolean showPhoneNumber;

}
