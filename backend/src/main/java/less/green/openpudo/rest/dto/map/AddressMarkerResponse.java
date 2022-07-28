package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class AddressMarkerResponse extends TypedResponse<AddressMarker> {

    public AddressMarkerResponse(UUID executionId, int returnCode, AddressMarker payload) {
        super(executionId, returnCode, payload);
    }

}
