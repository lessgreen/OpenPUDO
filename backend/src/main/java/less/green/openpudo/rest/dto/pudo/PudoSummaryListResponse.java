package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class PudoSummaryListResponse extends TypedResponse<List<PudoSummary>> {

    public PudoSummaryListResponse(UUID executionId, int returnCode, List<PudoSummary> payload) {
        super(executionId, returnCode, payload);
    }

}
