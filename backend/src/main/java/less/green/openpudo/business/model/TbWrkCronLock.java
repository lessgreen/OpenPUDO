package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.time.Instant;

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
    private Instant acquireTms;

    @Column(name = "lease_tms")
    private Instant leaseTms;

}
