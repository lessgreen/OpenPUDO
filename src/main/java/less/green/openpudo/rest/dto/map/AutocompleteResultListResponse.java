package less.green.openpudo.rest.dto.map;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class AutocompleteResultListResponse extends BaseResponse<List<AutocompleteResult>> {

    public AutocompleteResultListResponse(UUID executionId, int returnCode) {
        super(executionId, returnCode);
    }

    public AutocompleteResultListResponse(UUID executionId, int returnCode, String message) {
        super(executionId, returnCode, message);
    }

    public AutocompleteResultListResponse(UUID executionId, int returnCode, List<AutocompleteResult> payload) {
        super(executionId, returnCode, payload);
    }

}
