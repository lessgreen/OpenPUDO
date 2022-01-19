package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class UserResponse extends TypedResponse<User> {

    public UserResponse(UUID executionId, int returnCode, User payload) {
        super(executionId, returnCode, payload);
    }

}
