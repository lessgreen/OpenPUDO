package less.green.openpudo.rest.dto.map;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum MarkerType {
    @JsonProperty(value = "pudo")
    PUDO,
    @JsonProperty(value = "address")
    ADDRESS
}
