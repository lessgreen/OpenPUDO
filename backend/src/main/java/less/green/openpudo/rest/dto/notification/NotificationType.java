package less.green.openpudo.rest.dto.notification;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"favourite", "package"})
public enum NotificationType {
    @JsonProperty("favourite")
    FAVOURITE("favourite"),
    @JsonProperty("package")
    PACKAGE("package");

    @Getter
    private final String value;

    NotificationType(String value) {
        this.value = value;
    }
}
