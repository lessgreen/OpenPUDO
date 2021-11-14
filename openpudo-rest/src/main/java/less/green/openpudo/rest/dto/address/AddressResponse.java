package less.green.openpudo.rest.dto.address;

import less.green.openpudo.rest.dto.BaseResponse;

import java.util.UUID;

public class AddressResponse extends BaseResponse<Address> {

    public AddressResponse(UUID executionId, int returnCode, Address payload) {
        super(executionId, returnCode, payload);
    }

}
