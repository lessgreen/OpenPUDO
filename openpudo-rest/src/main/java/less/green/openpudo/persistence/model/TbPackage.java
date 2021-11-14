package less.green.openpudo.persistence.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_package")
@Getter
@Setter
@ToString
public class TbPackage implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "package_id", insertable = false, updatable = false)
    private Long packageId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

    @Column(name = "pudo_id")
    private Long pudoId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "package_pic_id")
    private UUID packagePicId;

}
