package less.green.openpudo.rest.dto.map;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class MarkerListResponse extends BaseResponse<List<Marker>> {

    public MarkerListResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public MarkerListResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public MarkerListResponse(UUID executionId, int returnCode, List<Marker> payload) {
        super(executionId, returnCode, payload);
    }

}
