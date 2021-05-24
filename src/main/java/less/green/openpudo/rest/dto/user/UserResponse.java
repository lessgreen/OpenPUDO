package less.green.openpudo.rest.dto.user;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class UserResponse extends BaseResponse<User> {

    public UserResponse(UUID executionId, int returnCode, User payload) {
        super(executionId, returnCode, payload);
    }

}
