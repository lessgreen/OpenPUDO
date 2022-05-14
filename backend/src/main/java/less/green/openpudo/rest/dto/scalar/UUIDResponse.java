package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class UUIDResponse extends TypedResponse<UUID> {

    public UUIDResponse(UUID executionId, int returnCode, UUID payload) {
        super(executionId, returnCode, payload);
    }

}
