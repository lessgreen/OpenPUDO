package less.green.openpudo.rest.dto.pudo.reward;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class RewardOptionListResponse extends TypedResponse<List<RewardOption>> {

    public RewardOptionListResponse(UUID executionId, int returnCode, List<RewardOption> payload) {
        super(executionId, returnCode, payload);
    }

}
