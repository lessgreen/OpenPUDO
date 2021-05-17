package less.green.openpudo.rest.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import java.io.Serializable;
import java.util.Date;
import lombok.Data;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Data
public class Address implements Serializable {

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    private Long addressId;

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date createTms;

    @Schema(readOnly = true, description = "This field is read-only, any change made by caller will be discarded")
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Date updateTms;

    private String street;

    private String streetNum;

    private String zipCode;

    private String city;

    private String province;

    private String country;

    private String notes;

    private Double lat;

    private Double lon;

}
