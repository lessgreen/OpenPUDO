package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class SignedAddressMarkerListResponse extends TypedResponse<List<SignedAddressMarker>> {

    public SignedAddressMarkerListResponse(UUID executionId, int returnCode, List<SignedAddressMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
