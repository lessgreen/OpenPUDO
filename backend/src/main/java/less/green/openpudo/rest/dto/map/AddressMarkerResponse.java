package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class AddressMarkerResponse extends TypedResponse<AddressMarker> {

    public AddressMarkerResponse(UUID executionId, int returnCode, AddressMarker payload) {
        super(executionId, returnCode, payload);
    }

}
