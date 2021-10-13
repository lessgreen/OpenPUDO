package less.green.openpudo.persistence.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;

@Entity
@Table(name = "tb_pudo_address")
@IdClass(TbPudoAddressPK.class)
@Getter
@Setter
@ToString
public class TbPudoAddress implements Serializable {

    @Id
    @Column(name = "pudo_id", updatable = false)
    private Long pudoId;

    @Id
    @Column(name = "address_id", updatable = false)
    private Long addressId;

}
