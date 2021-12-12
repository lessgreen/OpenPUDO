package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class LoginConfirmResponse extends TypedResponse<AccessTokenData> {

    public LoginConfirmResponse(UUID executionId, int returnCode, AccessTokenData payload) {
        super(executionId, returnCode, payload);
    }

}
