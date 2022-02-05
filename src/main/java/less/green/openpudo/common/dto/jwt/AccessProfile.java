package less.green.openpudo.common.dto.jwt;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"guest", "pudo", "customer"})
public enum AccessProfile {
    @JsonProperty("guest")
    GUEST,
    @JsonProperty("pudo")
    PUDO,
    @JsonProperty("customer")
    CUSTOMER
}
