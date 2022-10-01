package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class AddressMarkerListResponse extends TypedResponse<List<AddressMarker>> {

    public AddressMarkerListResponse(UUID executionId, int returnCode, List<AddressMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
