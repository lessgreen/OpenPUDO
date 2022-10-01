package less.green.openpudo.rest.dto.pack;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class PackageResponse extends TypedResponse<Package> {

    public PackageResponse(UUID executionId, int returnCode, Package payload) {
        super(executionId, returnCode, payload);
    }

}
