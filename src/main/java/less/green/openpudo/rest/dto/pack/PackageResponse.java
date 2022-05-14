package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class PackageResponse extends TypedResponse<Package> {

    public PackageResponse(UUID executionId, int returnCode, Package payload) {
        super(executionId, returnCode, payload);
    }

}
