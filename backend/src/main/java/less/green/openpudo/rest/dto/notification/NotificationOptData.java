package less.green.openpudo.rest.dto.notification;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Schema
public abstract class NotificationOptData {

    @Schema(readOnly = true)
    private NotificationType notificationType;

    @Schema(readOnly = true)
    private String notificationId;

    public abstract Map<String, String> toMap();

}
