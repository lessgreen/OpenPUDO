package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

@Entity
@Table(name = "tb_reward_policy")
@Getter
@Setter
@ToString
public class TbRewardPolicy implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "reward_policy_id", insertable = false, updatable = false)
    private Long rewardPolicyId;

    @Column(name = "pudo_id")
    private Long pudoId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "delete_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date deleteTms;

    @Column(name = "free_checked")
    private Boolean freeChecked;

    @Column(name = "customer_checked")
    private Boolean customerChecked;

    @Column(name = "customer_selectitem")
    private String customerSelectitem;

    @Column(name = "customer_selectitem_text")
    private String customerSelectitemText;

    @Column(name = "members_checked")
    private Boolean membersChecked;

    @Column(name = "members_text")
    private String membersText;

    @Column(name = "buy_checked")
    private Boolean buyChecked;

    @Column(name = "buy_text")
    private String buyText;

    @Column(name = "fee_checked")
    private Boolean feeChecked;

    @Column(name = "fee_price")
    private BigDecimal feePrice;

}
