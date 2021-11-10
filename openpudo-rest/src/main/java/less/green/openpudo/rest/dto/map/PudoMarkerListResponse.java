package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.List;
import java.util.UUID;

public class PudoMarkerListResponse extends BaseResponse<List<PudoMarker>> {

    public PudoMarkerListResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public PudoMarkerListResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public PudoMarkerListResponse(UUID executionId, int returnCode, List<PudoMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
