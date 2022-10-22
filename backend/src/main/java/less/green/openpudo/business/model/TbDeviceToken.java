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
@Table(name = "tb_device_token")
@Getter
@Setter
@ToString
public class TbDeviceToken implements Serializable {

    @Id
    @Column(name = "device_token", updatable = false)
    private String deviceToken;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "create_tms")
    private Instant createTms;

    @Column(name = "update_tms")
    private Instant updateTms;

    @Column(name = "device_type")
    private String deviceType;

    @Column(name = "system_name")
    private String systemName;

    @Column(name = "system_version")
    private String systemVersion;

    @Column(name = "model")
    private String model;

    @Column(name = "resolution")
    private String resolution;

    @Column(name = "application_language")
    private String applicationLanguage;

    @Column(name = "last_success_tms")
    private Instant lastSuccessTms;

    @Column(name = "last_success_message_id")
    private String lastSuccessMessageId;

    @Column(name = "last_failure_tms")
    private Instant lastFailureTms;

    @Column(name = "failure_count")
    private Integer failureCount;

}
