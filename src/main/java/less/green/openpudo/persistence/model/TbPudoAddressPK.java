package less.green.openpudo.persistence.model;

import java.io.Serializable;
import lombok.Data;

@Data
public class TbPudoAddressPK implements Serializable {

    private Long pudoId;
    private Long addressId;

}
