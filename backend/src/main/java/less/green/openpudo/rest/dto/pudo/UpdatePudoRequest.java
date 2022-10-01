package less.green.openpudo.rest.dto.pudo;

import less.green.openpudo.rest.dto.map.AddressMarker;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema
public class UpdatePudoRequest {

    private Pudo pudo;

    private AddressMarker addressMarker;

}
