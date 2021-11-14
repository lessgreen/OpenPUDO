package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.UUID;

public class UserResponse extends BaseResponse<User> {

    public UserResponse(UUID executionId, int returnCode, User payload) {
        super(executionId, returnCode, payload);
    }

}
