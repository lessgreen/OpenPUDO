package less.green.openpudo.rest.dto.map;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.List;
import java.util.UUID;

@Schema
public class GPSMarkerListResponse extends TypedResponse<List<GPSMarker>> {

    public GPSMarkerListResponse(UUID executionId, int returnCode, List<GPSMarker> payload) {
        super(executionId, returnCode, payload);
    }

}
