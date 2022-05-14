package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.List;
import java.util.UUID;

public class UserSummaryListResponse extends TypedResponse<List<UserSummary>> {

    public UserSummaryListResponse(UUID executionId, int returnCode, List<UserSummary> payload) {
        super(executionId, returnCode, payload);
    }

}
