package less.green.openpudo.rest.dto.map;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AddressMarker {

    private String label;

    private String street;

    private String streetNum;

    private String zipCode;

    private String city;

    private String province;

    private String country;

    private BigDecimal lat;

    private BigDecimal lon;

    private BigDecimal distanceFromOrigin;

    private String addressSignature;

}
