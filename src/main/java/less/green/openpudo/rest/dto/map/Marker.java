package less.green.openpudo.rest.dto.map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Marker {

    private MarkerType type;

    @Schema(anyOf = {PudoMarker.class, AddressMarker.class})
    private Object marker;

}
