package less.green.openpudo.rest.dto.pack;

import com.fasterxml.jackson.annotation.JsonFormat;
import less.green.openpudo.business.model.usertype.PackageStatus;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Date;
import java.util.UUID;

@Data
public class PackageSummary {

    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    private PackageStatus packageStatus;

    @Schema(readOnly = true)
    private UUID packagePicId;

    @Schema(readOnly = true)
    private String packageName;

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private String businessName;

    @Schema(readOnly = true)
    private String label;

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private String firstName;

    @Schema(readOnly = true)
    private String lastName;

    @Schema(readOnly = true)
    private String customerSuffix;

}
