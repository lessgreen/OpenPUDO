package less.green.openpudo.persistence.model;

import less.green.openpudo.persistence.model.usertype.AccountType;
import less.green.openpudo.persistence.model.usertype.AccountTypeConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_user")
@Getter
@Setter
@ToString
public class TbUser implements Serializable {

    @Id
    @Column(name = "user_id", updatable = false)
    private Long userId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "last_login_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date lastLoginTms;

    @Column(name = "account_type")
    @Convert(converter = AccountTypeConverter.class)
    private AccountType accountType;

    @Column(name = "test_account_flag")
    private Boolean testAccountFlag;

    @Column(name = "phone_number")
    private String phoneNumber;

}
