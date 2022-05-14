package less.green.openpudo.rest.dto.notification;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class NotificationPackageOptData extends NotificationOptData {

    @Schema(readOnly = true)
    private String packageId;

    public NotificationPackageOptData(String notificationId, String packageId) {
        super(NotificationType.PACKAGE, notificationId);
        this.packageId = packageId;
    }

    @Override
    public Map<String, String> toMap() {
        return Map.of(
                "notificationType", getNotificationType().getValue(),
                "notificationId", getNotificationId(),
                "packageId", packageId
        );
    }

}
