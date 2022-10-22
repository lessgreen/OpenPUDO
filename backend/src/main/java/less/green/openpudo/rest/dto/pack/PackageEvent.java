package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.business.model.usertype.PackageStatus;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;

@Data
@Schema
public class PackageEvent {

    @Schema(readOnly = true)
    private Long packageEventId;

    @Schema(readOnly = true)
    private Instant createTms;

    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    private PackageStatus packageStatus;

    @Schema(readOnly = true)
    private String packageStatusMessage;

    @Schema(readOnly = true)
    private Boolean autoFlag;

    @Schema(readOnly = true)
    private String notes;

}
