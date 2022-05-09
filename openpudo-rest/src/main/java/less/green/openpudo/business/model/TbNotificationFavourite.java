package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "tb_notification_favourite")
@Getter
@Setter
@ToString(callSuper = true)
public class TbNotificationFavourite extends TbNotification implements Serializable {

    @Column(name = "customer_user_id")
    private Long customerUserId;

    @Column(name = "pudo_id")
    private Long pudoId;

}
