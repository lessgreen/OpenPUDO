package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.ALWAYS)
@Schema(oneOf = {ExtraInfoText.class, ExtraInfoDecimal.class, ExtraInfoSelect.class})
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.EXISTING_PROPERTY, property = "type", defaultImpl = ExtraInfoType.class, visible = true)
@JsonSubTypes({
        @JsonSubTypes.Type(value = ExtraInfoText.class, name = "text"),
        @JsonSubTypes.Type(value = ExtraInfoDecimal.class, name = "decimal"),
        @JsonSubTypes.Type(value = ExtraInfoSelect.class, name = "select")
})
public abstract class ExtraInfo {

    @Schema(required = true)
    private String name;

    @Schema(readOnly = true)
    private String text;

    @Schema(required = true)
    private ExtraInfoType type;

    @Schema(readOnly = true)
    private Boolean mandatoryValue;

}
