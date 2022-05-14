package less.green.openpudo.rest.dto.pudo.reward;

import com.fasterxml.jackson.annotation.JsonProperty;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"smile", "card", "bag", "money"})
public enum RewardIcon {
    @JsonProperty("smile")
    SMILE,
    @JsonProperty("card")
    CARD,
    @JsonProperty("bag")
    BAG,
    @JsonProperty("money")
    MONEY
}
