package less.green.openpudo.rest.dto.pudo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.Date;
import java.util.UUID;

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

    private String publicPhoneNumber;

    @Schema(readOnly = true)
    private UUID pudoPicId;

    @Schema(readOnly = true)
    private Address address;

    @Schema(readOnly = true)
    private String rewardMessage;

    @Schema(readOnly = true)
    private Rating rating;

    @Schema(readOnly = true)
    private Long customerCount;

    @Schema(readOnly = true)
    private Long packageCount;

}
