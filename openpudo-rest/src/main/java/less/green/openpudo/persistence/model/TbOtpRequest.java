package less.green.openpudo.persistence.model;

import less.green.openpudo.persistence.dao.usertype.OtpRequestType;
import less.green.openpudo.persistence.dao.usertype.OtpRequestTypeConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_otp_request")
@Getter
@Setter
@ToString
public class TbOtpRequest implements Serializable {

    @Id
    @Column(name = "request_id", updatable = false)
    private UUID requestId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

    @Column(name = "request_type")
    @Convert(converter = OtpRequestTypeConverter.class)
    private OtpRequestType requestType;

    @Column(name = "otp")
    private String otp;

    @Column(name = "retry_count")
    private Integer retryCount;

}
