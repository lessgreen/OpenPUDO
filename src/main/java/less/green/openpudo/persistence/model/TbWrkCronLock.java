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
@Table(name = "tb_wrk_cron_lock")
@Getter @Setter @ToString
public class TbWrkCronLock implements Serializable {

    @Id
    @Column(name = "lock_name", updatable = false)
    private String lockName;

    @Column(name = "acquired_flag")
    private Boolean acquiredFlag;

    @Column(name = "acquire_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date acquireTms;

    @Column(name = "lease_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date leaseTms;

}
