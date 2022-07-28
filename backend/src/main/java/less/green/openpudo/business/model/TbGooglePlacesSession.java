package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_google_places_session")
@Getter
@Setter
@ToString
public class TbGooglePlacesSession implements Serializable {

    @Id
    @Column(name = "session_id", updatable = false)
    private UUID sessionId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "phone_number")
    private String phoneNumber;

}
