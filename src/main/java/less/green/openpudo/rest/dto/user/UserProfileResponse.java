package less.green.openpudo.rest.dto.user;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class UserProfileResponse extends BaseResponse<UserProfile> {

    public UserProfileResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public UserProfileResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public UserProfileResponse(UUID executionId, int returnCode, UserProfile payload) {
        super(executionId, returnCode, payload);
    }

}
