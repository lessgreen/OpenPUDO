package less.green.openpudo.rest.dto.notification;

import java.util.Map;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class TestPushNotification {

    @Schema(required = true)
    private String password;

    @Schema(required = true)
    private Long userId;

    @Schema(required = true)
    private String title;

    @Schema(required = true)
    private String message;

    @Schema(required = true)
    private Map<String, String> optData;

}
