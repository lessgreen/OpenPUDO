package less.green.openpudo.rest.dto.map.pack;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class PackageEvent {

    @Schema(readOnly = true)
    private Long packageEventId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    private Long packageId;

    @Schema(readOnly = true)
    private PackageStatus packageStatus;

    @Schema(readOnly = true)
    private String notes;

}
