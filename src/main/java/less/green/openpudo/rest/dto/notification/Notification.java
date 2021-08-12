package less.green.openpudo.rest.dto.notification;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonRawValue;
import java.util.Date;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class Notification {

    public enum NotificationType {
        PACKAGE
    }

    @Schema(readOnly = true)
    private Long notificationId;

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date readTms;

    @Schema(readOnly = true)
    private String title;

    @Schema(readOnly = true)
    private String message;

    @Schema(readOnly = true)
    @JsonRawValue
    private Object optData;

}
