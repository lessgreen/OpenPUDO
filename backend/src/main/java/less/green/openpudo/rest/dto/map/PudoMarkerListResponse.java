package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class PudoMarkerListResponse extends TypedResponse<List<PudoMarker>> {

    public PudoMarkerListResponse(UUID executionId, int returnCode, List<PudoMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
