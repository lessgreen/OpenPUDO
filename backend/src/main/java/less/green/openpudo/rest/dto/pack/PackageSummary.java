package less.green.openpudo.rest.dto.pack;

import com.fasterxml.jackson.annotation.JsonFormat;
import less.green.openpudo.business.model.usertype.PackageStatus;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.UUID;

@Data
@Schema
public class PackageSummary {

    // from package
    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant createTms;

    @Schema(readOnly = true)
    private UUID packagePicId;

    @Schema(readOnly = true)
    private String packageName;

    // from the latest package event
    @Schema(readOnly = true)
    private PackageStatus packageStatus;

    // from pudo
    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private String businessName;

    // from pudo address
    @Schema(readOnly = true)
    private String label;

    // from user profile
    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private String firstName;

    @Schema(readOnly = true)
    private String lastName;

    // from relation
    @Schema(readOnly = true)
    private String customerSuffix;

}
