package less.green.openpudo.persistence.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_address")
@Getter @Setter @ToString
public class TbAddress implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "address_id", insertable = false, updatable = false)
    private Long addressId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

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
