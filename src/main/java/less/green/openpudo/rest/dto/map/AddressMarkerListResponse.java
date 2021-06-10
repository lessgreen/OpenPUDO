package less.green.openpudo.rest.dto.map;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class AddressMarkerListResponse extends BaseResponse<List<AddressMarker>> {

    public AddressMarkerListResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public AddressMarkerListResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public AddressMarkerListResponse(UUID executionId, int returnCode, List<AddressMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
