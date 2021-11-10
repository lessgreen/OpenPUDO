package less.green.openpudo.persistence.model;

import lombok.Data;

import java.io.Serializable;

@Data
public class TbPudoAddressPK implements Serializable {

    private Long pudoId;
    private Long addressId;

}
