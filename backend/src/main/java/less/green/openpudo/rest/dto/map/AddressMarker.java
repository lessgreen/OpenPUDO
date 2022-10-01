package less.green.openpudo.rest.dto.map;

import lombok.Data;
import lombok.ToString;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@ToString(callSuper = true)
@Schema
public class AddressMarker extends GPSMarker {

    @Schema(required = true)
    private AddressSearchResult address;

}
