package less.green.openpudo.persistence.model;

import java.io.Serializable;
import lombok.Data;

@Data
public class TbUserAddressPK implements Serializable {

    private Long userId;
    private Long addressId;

}
