package less.green.openpudo.rest.dto.pudo;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.UUID;

@Data
@Schema
public class Pudo {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private Instant createTms;

    @Schema(readOnly = true)
    private Instant updateTms;

    @Schema(required = true)
    private String businessName;

    private String publicPhoneNumber;

    private String email;

    @Schema(readOnly = true)
    private UUID pudoPicId;

    @Schema(readOnly = true)
    private Address address;

    @Schema(readOnly = true)
    private Rating rating;

    @Schema(readOnly = true)
    private String rewardMessage;

    @Schema(readOnly = true)
    private Long customerCount;

    @Schema(readOnly = true)
    private Long packageCount;

    @Schema(readOnly = true)
    private String savedCO2;

    @Schema(readOnly = true)
    private String customizedAddress;

}
