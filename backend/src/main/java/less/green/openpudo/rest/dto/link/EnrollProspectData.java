package less.green.openpudo.rest.dto.link;

import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.rest.dto.map.AddressMarker;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
@Schema
public class EnrollProspectData extends DynamicLinkData {

    @Schema(readOnly = true)
    private AccessTokenData accessTokenData;

    @Schema(readOnly = true)
    private String phoneNumber;

    @Schema(readOnly = true)
    private AccountType accountType;

    // customer specific fields
    @Schema(readOnly = true)
    private String firstName;

    @Schema(readOnly = true)
    private String lastName;

    @Schema(readOnly = true)
    private Long favouritePudoId;

    // PUDO specific fields
    @Schema(readOnly = true)
    private String businessName;

    @Schema(readOnly = true)
    private AddressMarker addressMarker;

}
