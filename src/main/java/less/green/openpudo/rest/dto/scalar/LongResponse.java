package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.UUID;

public class LongResponse extends BaseResponse<Long> {

    public LongResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public LongResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public LongResponse(UUID executionId, int returnCode, Long payload) {
        super(executionId, returnCode, payload);
    }

}
