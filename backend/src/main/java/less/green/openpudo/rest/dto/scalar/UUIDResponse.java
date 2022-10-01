package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class UUIDResponse extends TypedResponse<UUID> {

    public UUIDResponse(UUID executionId, int returnCode, UUID payload) {
        super(executionId, returnCode, payload);
    }

}
