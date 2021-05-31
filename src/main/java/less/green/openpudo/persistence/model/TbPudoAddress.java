package less.green.openpudo.persistence.model;

import java.io.Serializable;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.IdClass;
import javax.persistence.Table;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_pudo_address")
@IdClass(TbPudoAddressPK.class)
@Getter @Setter @ToString
public class TbPudoAddress implements Serializable {

    @Id
    @Column(name = "pudo_id", updatable = false)
    private Long pudoId;

    @Id
    @Column(name = "address_id", updatable = false)
    private Long addressId;

}
