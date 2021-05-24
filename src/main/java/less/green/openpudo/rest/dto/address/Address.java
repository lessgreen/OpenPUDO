package less.green.openpudo.rest.dto.address;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.io.Serializable;
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

    @Schema(required = true)
    private String street;

    private String streetNum;

    @Schema(required = true)
    private String zipCode;

    @Schema(required = true)
    private String city;

    @Schema(required = true)
    private String province;

    @Schema(required = true)
    private String country;

    private String notes;

    @Schema(required = true)
    private Double lat;

    @Schema(required = true)
    private Double lon;

}
