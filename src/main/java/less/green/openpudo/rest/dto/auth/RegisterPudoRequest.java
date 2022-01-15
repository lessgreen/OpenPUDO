package less.green.openpudo.rest.dto.auth;

import less.green.openpudo.rest.dto.map.SignedAddressMarker;
import less.green.openpudo.rest.dto.pudo.Pudo;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class RegisterPudoRequest {

    @Schema(required = true)
    private Pudo pudo;

    @Schema(required = true)
    private SignedAddressMarker signedAddressMarker;

}
