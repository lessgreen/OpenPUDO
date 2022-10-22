package less.green.openpudo.business.model;

import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.AccountTypeConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "tb_user")
@Getter
@Setter
@ToString
public class TbUser implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id", insertable = false, updatable = false)
    private Long userId;

    @Column(name = "create_tms")
    private Instant createTms;

    @Column(name = "last_login_tms")
    private Instant lastLoginTms;

    @Column(name = "account_type")
    @Convert(converter = AccountTypeConverter.class)
    private AccountType accountType;

    @Column(name = "test_account_flag")
    private Boolean testAccountFlag;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "dynamic_link_id")
    private UUID dynamicLinkId;

}
