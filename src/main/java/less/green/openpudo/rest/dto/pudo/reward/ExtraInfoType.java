package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"text", "decimal", "select"})
public enum ExtraInfoType {
    @JsonProperty("text")
    TEXT,
    @JsonProperty("decimal")
    DECIMAL,
    @JsonProperty("select")
    SELECT
}
