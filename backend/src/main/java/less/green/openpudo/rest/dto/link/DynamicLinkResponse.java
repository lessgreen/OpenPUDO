package less.green.openpudo.rest.dto.link;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class DynamicLinkResponse extends TypedResponse<DynamicLink> {

    public DynamicLinkResponse(UUID executionId, int returnCode, DynamicLink payload) {
        super(executionId, returnCode, payload);
    }

}
