package less.green.openpudo.rest.dto.file;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class ExternalFileResponse extends BaseResponse<ExternalFile> {

    public ExternalFileResponse(UUID executionId, int returnCode, ExternalFile payload) {
        super(executionId, returnCode, payload);
    }

}
