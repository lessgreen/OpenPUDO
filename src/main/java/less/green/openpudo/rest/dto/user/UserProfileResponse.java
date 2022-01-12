package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class UserProfileResponse extends TypedResponse<UserProfile> {

    public UserProfileResponse(UUID executionId, int returnCode, UserProfile payload) {
        super(executionId, returnCode, payload);
    }

}
