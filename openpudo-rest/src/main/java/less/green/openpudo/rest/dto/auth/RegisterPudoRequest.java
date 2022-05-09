package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.reward.RewardOption;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;

@Data
public class RegisterPudoRequest {

    @Schema(required = true)
    private Pudo pudo;

    @Schema(required = true)
    private AddressMarker addressMarker;

    @Schema(required = true)
    private List<RewardOption> rewardPolicy;

}
