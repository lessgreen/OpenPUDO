package less.green.openpudo.rest.dto.notification;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Map;

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
