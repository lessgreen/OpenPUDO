package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class PudoMarkerListResponse extends TypedResponse<List<PudoMarker>> {

    public PudoMarkerListResponse(UUID executionId, int returnCode, List<PudoMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
