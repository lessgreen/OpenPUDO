package less.green.openpudo.rest.dto.address;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class Address implements Serializable {

    @Schema(readOnly = true)
    private Long addressId;

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
