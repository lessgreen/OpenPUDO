package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_deleted_user_data")
@Getter
@Setter
@ToString
public class TbDeletedUserData implements Serializable {

    @Id
    @Column(name = "user_data_id", updatable = false)
    private UUID userDataId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "user_data")
    private String userData;

}
