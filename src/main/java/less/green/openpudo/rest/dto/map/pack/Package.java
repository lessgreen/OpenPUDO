package less.green.openpudo.rest.dto.map.pack;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class Package {

    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    private PackageStatus packageStatus;

    @Schema(readOnly = true)
    private UUID packagePicId;

    @Schema(readOnly = true)
    private List<PackageEvent> events;

}
