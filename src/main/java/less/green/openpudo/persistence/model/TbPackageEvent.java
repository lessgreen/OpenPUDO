package less.green.openpudo.persistence.model;

import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.dao.usertype.PackageStatusConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_package_event")
@Getter
@Setter
@ToString
public class TbPackageEvent implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "package_event_id", insertable = false, updatable = false)
    private Long packageEventId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "package_id")
    private Long packageId;

    @Column(name = "package_status")
    @Convert(converter = PackageStatusConverter.class)
    private PackageStatus packageStatus;

    @Column(name = "notes")
    private String notes;

}
