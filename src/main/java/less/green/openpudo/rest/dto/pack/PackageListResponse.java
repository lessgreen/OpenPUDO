package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.List;
import java.util.UUID;

public class PackageListResponse extends BaseResponse<List<Package>> {

    public PackageListResponse(UUID executionId, int returnCode, List<Package> payload) {
        super(executionId, returnCode, payload);
    }

}
