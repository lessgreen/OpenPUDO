package less.green.openpudo.persistence.model;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Convert;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import less.green.openpudo.persistence.dao.usertype.StringArrayConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_notification")
@Getter @Setter @ToString
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

    @Column(name = "opt_data")
    private String optData;

}
