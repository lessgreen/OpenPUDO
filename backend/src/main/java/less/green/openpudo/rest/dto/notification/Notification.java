package less.green.openpudo.rest.dto.notification;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.time.Instant;
import java.util.Map;

@Data
@Schema
public class Notification {

    @Schema(readOnly = true)
    private Long notificationId;

    @Schema(readOnly = true)
    private Long userId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant readTms;

    @Schema(readOnly = true)
    private String title;

    @Schema(readOnly = true)
    private String message;

    @Schema(readOnly = true, oneOf = {NotificationFavouriteOptData.class, NotificationPackageOptData.class})
    private Map<String, String> optData;

}
