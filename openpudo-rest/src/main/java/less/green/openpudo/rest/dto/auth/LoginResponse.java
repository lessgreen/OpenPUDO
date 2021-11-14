package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.UUID;

public class LoginResponse extends BaseResponse<AccessTokenData> {

    public LoginResponse(UUID executionId, int returnCode, AccessTokenData payload) {
        super(executionId, returnCode, payload);
    }

}
