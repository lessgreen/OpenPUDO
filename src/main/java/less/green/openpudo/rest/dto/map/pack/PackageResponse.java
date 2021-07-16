package less.green.openpudo.rest.dto.map.pack;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class PackageResponse extends BaseResponse<Package> {

    public PackageResponse(UUID executionId, int returnCode, Package payload) {
        super(executionId, returnCode, payload);
    }

}
