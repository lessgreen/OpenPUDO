package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class PackageSummaryListResponse extends TypedResponse<List<PackageSummary>> {

    public PackageSummaryListResponse(UUID executionId, int returnCode, List<PackageSummary> payload) {
        super(executionId, returnCode, payload);
    }

}
