package less.green.openpudo.persistence.model;

import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.dao.usertype.RoleTypeConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_pudo_user_role")
@IdClass(TbPudoUserRolePK.class)
@Getter
@Setter
@ToString
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
    @Convert(converter = RoleTypeConverter.class)
    private RoleType roleType;

}
