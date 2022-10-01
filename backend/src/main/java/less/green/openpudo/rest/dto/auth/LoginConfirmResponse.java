package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class LoginConfirmResponse extends TypedResponse<AccessTokenData> {

    public LoginConfirmResponse(UUID executionId, int returnCode, AccessTokenData payload) {
        super(executionId, returnCode, payload);
    }

}
