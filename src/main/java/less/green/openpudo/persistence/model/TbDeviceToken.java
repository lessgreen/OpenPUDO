package less.green.openpudo.persistence.model;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_device_token")
@Getter @Setter @ToString
public class TbDeviceToken implements Serializable {

    @Id
    @Column(name = "device_token", updatable = false)
    private String deviceToken;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "last_access_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date lastAccessTms;

    @Column(name = "system_name")
    private String systemName;

    @Column(name = "system_version")
    private String systemVersion;

    @Column(name = "model")
    private String model;

    @Column(name = "resolution")
    private String resolution;

}
