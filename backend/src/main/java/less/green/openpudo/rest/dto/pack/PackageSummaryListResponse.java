package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class PackageSummaryListResponse extends TypedResponse<List<PackageSummary>> {

    public PackageSummaryListResponse(UUID executionId, int returnCode, List<PackageSummary> payload) {
        super(executionId, returnCode, payload);
    }

}
