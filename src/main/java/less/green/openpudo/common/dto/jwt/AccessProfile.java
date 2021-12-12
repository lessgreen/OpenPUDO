package less.green.openpudo.common.dto.jwt;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum AccessProfile {
    @JsonProperty("guest")
    GUEST,
    @JsonProperty("pudo")
    PUDO,
    @JsonProperty("customer")
    CUSTOMER
}
