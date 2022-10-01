package less.green.openpudo.rest.dto.link;

import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema(oneOf = {EnrollProspectData.class})
public abstract class DynamicLinkData {
}
