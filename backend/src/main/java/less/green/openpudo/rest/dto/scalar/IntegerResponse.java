package less.green.openpudo.rest.dto.scalar;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class IntegerResponse extends TypedResponse<Integer> {

    public IntegerResponse(UUID executionId, int returnCode, Integer payload) {
        super(executionId, returnCode, payload);
    }

}
