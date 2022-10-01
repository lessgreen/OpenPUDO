package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class PudoResponse extends TypedResponse<Pudo> {

    public PudoResponse(UUID executionId, int returnCode, Pudo payload) {
        super(executionId, returnCode, payload);
    }

}
