package less.green.openpudo.persistence.projection;

import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import lombok.Data;

@Data
public class PudoAndAddress {

    private TbPudo pudo;
    private TbAddress address;

}
