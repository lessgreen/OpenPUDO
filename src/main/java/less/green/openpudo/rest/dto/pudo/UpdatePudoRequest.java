package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.map.AddressMarker;
import lombok.Data;

@Data
public class UpdatePudoRequest {

    private Pudo pudo;

    private AddressMarker addressMarker;

}
