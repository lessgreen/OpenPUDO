package less.green.openpudo.rest.dto.link;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class DynamicLinkResponse extends TypedResponse<DynamicLink> {

    public DynamicLinkResponse(UUID executionId, int returnCode, DynamicLink payload) {
        super(executionId, returnCode, payload);
    }

}
