package less.green.openpudo.rest.dto.user;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.io.Serializable;
import java.util.Date;

@Data
public class UserPreferences implements Serializable {

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    @Schema(required = true)
    private Boolean showPhoneNumber;

}
