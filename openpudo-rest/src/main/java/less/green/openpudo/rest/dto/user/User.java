package less.green.openpudo.rest.dto.user;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Date;
import java.util.UUID;

@Data
public class User {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    @Schema(required = true)
    private String firstName;

    @Schema(required = true)
    private String lastName;

    private String ssn;

    @Schema(readOnly = true)
    private UUID profilePicId;

    @Schema(readOnly = true)
    private Boolean pudoOwner;

}
