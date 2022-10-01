package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class LongResponse extends TypedResponse<Long> {

    public LongResponse(UUID executionId, int returnCode, Long payload) {
        super(executionId, returnCode, payload);
    }

}
