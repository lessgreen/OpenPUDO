package less.green.openpudo.rest.dto.notification;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Date;
import java.util.Map;

@Data
public class Notification {

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

    @Schema(readOnly = true, oneOf = {NotificationFavouriteOptData.class, NotificationPackageOptData.class})
    private Map<String, String> optData;

}
