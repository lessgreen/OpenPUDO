package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.List;
import java.util.UUID;

public class PudoListResponse extends BaseResponse<List<Pudo>> {

    public PudoListResponse(UUID executionId, int returnCode, List<Pudo> payload) {
        super(executionId, returnCode, payload);
    }

}
