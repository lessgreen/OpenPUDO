package less.green.openpudo.rest.dto.pudo;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class PudoResponse extends BaseResponse<Pudo> {

    public PudoResponse(UUID executionId, int returnCode, Pudo payload) {
        super(executionId, returnCode, payload);
    }

}
