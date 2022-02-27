package less.green.openpudo.rest.dto.notification;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Map;

@Data
public class NotificationFavouriteOptData extends NotificationOptData {

    @Schema(readOnly = true)
    private String userId;

    @Schema(readOnly = true)
    private String pudoId;

    public NotificationFavouriteOptData(String notificationId, String userId, String pudoId) {
        super(NotificationType.FAVOURITE, notificationId);
        this.userId = userId;
        this.pudoId = pudoId;
    }

    @Override
    public Map<String, String> toMap() {
        return Map.of(
                "notificationType", getNotificationType().getValue(),
                "notificationId", getNotificationId(),
                "userId", userId,
                "pudoId", pudoId
        );
    }

}
