package less.green.openpudo.rest.dto.pudo;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.math.BigDecimal;
import java.util.Date;

@Data
public class Address {

    @Schema(readOnly = true)
    private Long pudoId;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true)
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    @Schema(readOnly = true)
    private String label;

    @Schema(readOnly = true)
    private String street;

    @Schema(readOnly = true)
    private String streetNum;

    @Schema(readOnly = true)
    private String zipCode;

    @Schema(readOnly = true)
    private String city;

    @Schema(readOnly = true)
    private String province;

    @Schema(readOnly = true)
    private String country;

    @Schema(readOnly = true)
    private BigDecimal lat;

    @Schema(readOnly = true)
    private BigDecimal lon;

}
