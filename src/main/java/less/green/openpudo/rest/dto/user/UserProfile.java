package less.green.openpudo.rest.dto.user;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Date;
import java.util.UUID;

@Data
public class UserProfile {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    private String firstName;

    private String lastName;

    @Schema(readOnly = true)
    private String phoneNumber;

    @Schema(readOnly = true)
    private UUID profilePicId;

    @Schema(readOnly = true)
    private Integer packageCount;

}
