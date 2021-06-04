package less.green.openpudo.rest.dto;

import java.io.Serializable;
import java.util.UUID;
import lombok.Data;

@Data
public class BaseResponse<T> implements Serializable {

    private UUID executionId;
    private int returnCode;
    private String message;
    private T payload;

    public BaseResponse(UUID executionId, int returnCode) {
        this.executionId = executionId;
        this.returnCode = returnCode;
    }

    public BaseResponse(UUID executionId, int returnCode, String message) {
        this.executionId = executionId;
        this.returnCode = returnCode;
        this.message = message;
    }

    public BaseResponse(UUID executionId, int returnCode, T payload) {
        this.executionId = executionId;
        this.returnCode = returnCode;
        this.payload = payload;
    }

}
