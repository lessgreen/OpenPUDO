package less.green.openpudo.rest.dto.user;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class DeviceToken {

    @Schema(required = true)
    private String deviceToken;

    private String systemName;

    private String systemVersion;

    private String model;

    private String resolution;

}
