package less.green.openpudo.rest.dto.scalar;

import com.fasterxml.jackson.databind.JsonNode;
import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class JsonResponse extends TypedResponse<JsonNode> {

    public JsonResponse(UUID executionId, int returnCode, JsonNode payload) {
        super(executionId, returnCode, payload);
    }

}
