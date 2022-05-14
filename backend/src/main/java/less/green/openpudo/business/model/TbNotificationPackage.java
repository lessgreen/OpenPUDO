package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Table;
import java.io.Serializable;

@Entity
@Table(name = "tb_notification_package")
@Getter
@Setter
@ToString(callSuper = true)
public class TbNotificationPackage extends TbNotification implements Serializable {

    @Column(name = "package_id")
    private Long packageId;

}
