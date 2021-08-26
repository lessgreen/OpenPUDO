package less.green.openpudo.rest.dto.notification;

import java.util.Map;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.rest.dto.notification.Notification.NotificationType;
import static less.green.openpudo.rest.dto.notification.Notification.NotificationType.PACKAGE;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class PackageNotificationOptData {

    @Schema(readOnly = true)
    private final NotificationType notificationType = PACKAGE;

    @Schema(readOnly = true)
    private final Long notificationId;

    @Schema(readOnly = true)
    private final Long packageId;

    @Schema(readOnly = true)
    private final PackageStatus packageStatus;

    public Map<String, String> toMap() {
        return Map.of(
                "notificationType", notificationType.toString(),
                "notificationId", notificationId.toString(),
                "packageId", packageId.toString(),
                "packageStatus", packageStatus.toString()
        );
    }

}
