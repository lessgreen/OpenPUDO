package less.green.openpudo.rest.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Data
@NoArgsConstructor
@Schema
public class BaseResponse {

    private UUID executionId;
    private int returnCode;
    private String message;

    public BaseResponse(UUID executionId, int returnCode) {
        this.executionId = executionId;
        this.returnCode = returnCode;
    }

    public BaseResponse(UUID executionId, int returnCode, String message) {
        this.executionId = executionId;
        this.returnCode = returnCode;
        this.message = message;
    }

}
