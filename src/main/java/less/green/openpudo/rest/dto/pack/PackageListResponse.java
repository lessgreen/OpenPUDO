package less.green.openpudo.rest.dto.pack;

import java.util.List;
import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class PackageListResponse extends BaseResponse<List<Package>> {

    public PackageListResponse(UUID executionId, int returnCode, List<Package> payload) {
        super(executionId, returnCode, payload);
    }

}
