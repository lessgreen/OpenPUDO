package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;
import java.time.Instant;

@Entity
@Table(name = "tb_address")
@Getter
@Setter
@ToString
public class TbAddress implements Serializable {

    @Id
    @Column(name = "pudo_id", updatable = false)
    private Long pudoId;

    @Column(name = "create_tms")
    private Instant createTms;

    @Column(name = "update_tms")
    private Instant updateTms;

    @Column(name = "label")
    private String label;

    @Column(name = "street")
    private String street;

    @Column(name = "street_num")
    private String streetNum;

    @Column(name = "zip_code")
    private String zipCode;

    @Column(name = "city")
    private String city;

    @Column(name = "province")
    private String province;

    @Column(name = "country")
    private String country;

    @Column(name = "lat")
    private BigDecimal lat;

    @Column(name = "lon")
    private BigDecimal lon;

}
