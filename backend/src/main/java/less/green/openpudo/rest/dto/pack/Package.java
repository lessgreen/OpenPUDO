package less.green.openpudo.rest.dto.pack;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Data
@Schema
public class Package {

    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant updateTms;

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private UUID packagePicId;

    @Schema(readOnly = true)
    private List<PackageEvent> events;

    // transient fields
    @Schema(readOnly = true)
    private String packageName;

    @Schema(readOnly = true)
    private String shareLink;

}
