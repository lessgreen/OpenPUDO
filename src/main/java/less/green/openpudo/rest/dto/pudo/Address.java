package less.green.openpudo.rest.dto.pudo;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class Address {

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

}
