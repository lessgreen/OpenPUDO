package less.green.openpudo.rest.dto.notification;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class NotificationListResponse extends BaseResponse<List<Notification>> {

    public NotificationListResponse(UUID executionId, int returnCode, List<Notification> payload) {
        super(executionId, returnCode, payload);
    }

}
