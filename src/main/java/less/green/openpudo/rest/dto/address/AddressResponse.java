package less.green.openpudo.rest.dto.address;

import java.util.UUID;
import less.green.openpudo.rest.dto.BaseResponse;

public class AddressResponse extends BaseResponse<Address> {

    public AddressResponse(UUID executionId, int returnCode, Address payload) {
        super(executionId, returnCode, payload);
    }

}
