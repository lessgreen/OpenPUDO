package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_wrk_cron_lock")
@Getter
@Setter
@ToString
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
