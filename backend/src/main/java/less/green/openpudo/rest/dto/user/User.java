package less.green.openpudo.rest.dto.user;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.UUID;

@Data
@Schema
public class User {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant updateTms;

    @Schema(required = true)
    private String firstName;

    @Schema(required = true)
    private String lastName;

    @Schema(readOnly = true)
    private UUID profilePicId;

    @Schema(readOnly = true)
    private String phoneNumber;

    @Schema(readOnly = true)
    private Long packageCount;

    @Schema(readOnly = true)
    private String savedCO2;

    @Schema(readOnly = true)
    private String customerSuffix;

}
