package less.green.openpudo.rest.dto.scalar;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class IntegerResponse extends BaseResponse<Integer> {

    public IntegerResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public IntegerResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public IntegerResponse(UUID executionId, int returnCode, Integer payload) {
        super(executionId, returnCode, payload);
    }

}
