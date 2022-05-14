package less.green.openpudo.business.model;

import less.green.openpudo.business.model.usertype.StringArrayConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_notification")
@Inheritance(strategy = InheritanceType.JOINED)
@Getter
@Setter
@ToString
public class TbNotification implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id", insertable = false, updatable = false)
    private Long notificationId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "queued_flag")
    private Boolean queuedFlag;

    @Column(name = "due_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date dueTms;

    @Column(name = "read_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date readTms;

    @Column(name = "title")
    private String title;

    @Column(name = "title_params")
    @Convert(converter = StringArrayConverter.class)
    private String[] titleParams;

    @Column(name = "message")
    private String message;

    @Column(name = "message_params")
    @Convert(converter = StringArrayConverter.class)
    private String[] messageParams;

}
