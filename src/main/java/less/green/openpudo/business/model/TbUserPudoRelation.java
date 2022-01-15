package less.green.openpudo.business.model;

import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.business.model.usertype.RelationTypeConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "tb_user_pudo_relation")
@Getter
@Setter
@ToString
public class TbUserPudoRelation implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_pudo_relation_id", insertable = false, updatable = false)
    private Long userPudoRelationId;

    @Column(name = "user_id")
    private Long userId;

    @Column(name = "pudo_id")
    private Long pudoId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "delete_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date deleteTms;

    @Column(name = "relation_type")
    @Convert(converter = RelationTypeConverter.class)
    private RelationType relationType;

    @Column(name = "customer_suffix")
    private String customerSuffix;

}
