package less.green.openpudo.rest.dto.link;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Map;

@Data
public class DynamicLink {

    @Schema(readOnly = true)
    private DynamicLinkRoute route;

    @Schema(readOnly = true)
    private Map<String, Object> payload;

}
