package less.green.openpudo.business.model.usertype;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"delivered", "notify_sent", "notified", "collected", "accepted", "expired"})
public enum PackageStatus {
    @JsonProperty("delivered")
    DELIVERED("delivered"),
    @JsonProperty("notify_sent")
    NOTIFY_SENT("notify_sent"),
    @JsonProperty("notified")
    NOTIFIED("notified"),
    @JsonProperty("collected")
    COLLECTED("collected"),
    @JsonProperty("accepted")
    ACCEPTED("accepted"),
    @JsonProperty("expired")
    EXPIRED("expired");

    @Getter
    private final String value;

    PackageStatus(String value) {
        this.value = value;
    }

}
