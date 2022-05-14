package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class StringResponse extends TypedResponse<String> {

    public StringResponse(UUID executionId, int returnCode, String payload) {
        super(executionId, returnCode, payload);
    }

}
