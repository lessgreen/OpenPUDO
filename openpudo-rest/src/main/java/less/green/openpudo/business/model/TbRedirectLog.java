package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_redirect_log")
@Getter
@Setter
@ToString
public class TbRedirectLog implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "redirect_id", insertable = false, updatable = false)
    private Long redirectId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "channel")
    private String channel;

    @Column(name = "remote_address")
    private String remoteAddress;

    @Column(name = "user_agent")
    private String userAgent;

}
