package less.green.openpudo.business.model;

import less.green.openpudo.business.model.usertype.OtpRequestType;
import less.green.openpudo.business.model.usertype.OtpRequestTypeConverter;
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

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

    @Column(name = "request_type")
    @Convert(converter = OtpRequestTypeConverter.class)
    private OtpRequestType requestType;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "otp")
    private String otp;

    @Column(name = "send_count")
    private Integer sendCount;

    // transient properties
    public String getRecipient() {
        if (userId != null) {
            return "user: " + userId;
        }
        return "phoneNumber: " + phoneNumber;
    }

}
