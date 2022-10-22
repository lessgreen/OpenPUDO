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
@Table(name = "tb_user_preferences")
@Getter
@Setter
@ToString
public class TbUserPreferences implements Serializable {

    @Id
    @Column(name = "user_id", updatable = false)
    private Long userId;

    @Column(name = "create_tms")
    private Instant createTms;

    @Column(name = "update_tms")
    private Instant updateTms;

    @Column(name = "show_phone_number")
    private Boolean showPhoneNumber;

}
