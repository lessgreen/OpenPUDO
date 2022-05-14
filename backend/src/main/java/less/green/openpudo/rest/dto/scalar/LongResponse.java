package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class LongResponse extends TypedResponse<Long> {

    public LongResponse(UUID executionId, int returnCode, Long payload) {
        super(executionId, returnCode, payload);
    }

}
