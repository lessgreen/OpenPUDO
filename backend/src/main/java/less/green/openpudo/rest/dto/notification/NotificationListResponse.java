package less.green.openpudo.rest.dto.notification;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class NotificationListResponse extends TypedResponse<List<Notification>> {

    public NotificationListResponse(UUID executionId, int returnCode, List<Notification> payload) {
        super(executionId, returnCode, payload);
    }

}
