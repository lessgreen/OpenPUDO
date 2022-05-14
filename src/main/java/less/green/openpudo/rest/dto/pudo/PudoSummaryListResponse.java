package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class PudoSummaryListResponse extends TypedResponse<List<PudoSummary>> {

    public PudoSummaryListResponse(UUID executionId, int returnCode, List<PudoSummary> payload) {
        super(executionId, returnCode, payload);
    }

}
