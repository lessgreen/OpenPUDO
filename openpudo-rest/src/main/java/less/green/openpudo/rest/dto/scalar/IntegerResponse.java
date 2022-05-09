package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class IntegerResponse extends TypedResponse<Integer> {

    public IntegerResponse(UUID executionId, int returnCode, Integer payload) {
        super(executionId, returnCode, payload);
    }

}
