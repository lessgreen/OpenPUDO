package less.green.openpudo.rest.dto.link;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"enroll-prospect"})
public enum DynamicLinkRoute {
    @JsonProperty("enroll-prospect")
    ENROLL_PROSPECT("enroll-prospect");

    @Getter
    private final String value;

    DynamicLinkRoute(String value) {
        this.value = value;
    }

}
