package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class GPSMarkerListResponse extends TypedResponse<List<GPSMarker>> {

    public GPSMarkerListResponse(UUID executionId, int returnCode, List<GPSMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
