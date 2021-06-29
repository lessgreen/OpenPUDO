package less.green.openpudo.rest.dto.user;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class UserListResponse extends BaseResponse<List<User>> {

    public UserListResponse(UUID executionId, int returnCode, List<User> payload) {
        super(executionId, returnCode, payload);
    }

}
