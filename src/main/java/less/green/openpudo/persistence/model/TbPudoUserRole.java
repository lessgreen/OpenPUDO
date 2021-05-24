package less.green.openpudo.persistence.model;

import java.io.Serializable;
import java.util.Date;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_pudo_user_role")
@IdClass(TbPudoUserRolePK.class)
@Getter @Setter @ToString
public class TbPudoUserRole implements Serializable {

    @Id
    @Column(name = "user_id", updatable = false)
    private Long userId;

    @Id
    @Column(name = "pudo_id", updatable = false)
    private Long pudoId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "role_type")
    private String roleType;

}
