package less.green.openpudo.rest.dto;

import lombok.Data;

import java.util.UUID;

@Data
public class TypedResponse<T> extends BaseResponse {

    private T payload;

    public TypedResponse(UUID executionId, int returnCode, T payload) {
        super(executionId, returnCode);
        this.payload = payload;
    }

}
