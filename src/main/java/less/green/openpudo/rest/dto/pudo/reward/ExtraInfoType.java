package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonProperty;

public enum ExtraInfoType {
    @JsonProperty("text")
    TEXT,
    @JsonProperty("decimal")
    DECIMAL,
    @JsonProperty("select")
    SELECT
}
