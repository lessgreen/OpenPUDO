package less.green.openpudo.rest.dto.pudo.reward;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class RewardOptionListResponse extends TypedResponse<List<RewardOption>> {

    public RewardOptionListResponse(UUID executionId, int returnCode, List<RewardOption> payload) {
        super(executionId, returnCode, payload);
    }

}
