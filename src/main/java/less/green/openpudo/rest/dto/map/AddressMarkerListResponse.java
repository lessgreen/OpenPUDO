package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class AddressMarkerListResponse extends TypedResponse<List<AddressMarker>> {

    public AddressMarkerListResponse(UUID executionId, int returnCode, List<AddressMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
