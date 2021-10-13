package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.UUID;

public class PudoResponse extends BaseResponse<Pudo> {

    public PudoResponse(UUID executionId, int returnCode, Pudo payload) {
        super(executionId, returnCode, payload);
    }

}
