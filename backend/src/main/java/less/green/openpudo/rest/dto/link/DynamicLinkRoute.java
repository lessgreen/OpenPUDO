package less.green.openpudo.rest.dto.link;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"home"})
public enum DynamicLinkRoute {
    @JsonProperty("home")
    HOME("home");

    @Getter
    private final String value;

    DynamicLinkRoute(String value) {
        this.value = value;
    }
}
