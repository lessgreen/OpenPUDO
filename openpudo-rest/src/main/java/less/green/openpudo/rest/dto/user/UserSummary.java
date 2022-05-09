package less.green.openpudo.rest.dto.user;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Data
public class UserSummary {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private String firstName;

    @Schema(readOnly = true)
    private String lastName;

    @Schema(readOnly = true)
    private UUID profilePicId;

    @Schema(readOnly = true)
    private String customerSuffix;

}
