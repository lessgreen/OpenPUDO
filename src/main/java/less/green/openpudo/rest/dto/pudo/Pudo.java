package less.green.openpudo.rest.dto.pudo;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.util.Date;
import java.util.UUID;
import less.green.openpudo.rest.dto.address.Address;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class Pudo {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    @Schema(required = true)
    private String businessName;

    private String vat;

    private String phoneNumber;

    private String contactNotes;

    @Schema(readOnly = true)
    private UUID profilePicId;

    @Schema(readOnly = true)
    private Address address;

}
