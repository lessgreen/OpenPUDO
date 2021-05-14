package less.green.openpudo.rest.dto.auth;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class LoginResponse extends BaseResponse<LoginResponsePayload> {

    public LoginResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public LoginResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public LoginResponse(UUID executionId, int returnCode, LoginResponsePayload payload) {
        super(executionId, returnCode, payload);
    }

}
