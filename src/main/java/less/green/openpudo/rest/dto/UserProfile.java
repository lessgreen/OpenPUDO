package less.green.openpudo.rest.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;
import java.util.UUID;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class UserProfile {

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    private Long userId;

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    private String firstName;

    private String lastName;

    private String ssn;

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    private UUID profilePicId;

}
