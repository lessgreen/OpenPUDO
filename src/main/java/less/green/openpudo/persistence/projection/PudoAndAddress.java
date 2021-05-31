package less.green.openpudo.persistence.projection;

import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PudoAndAddress {

    private TbPudo pudo;
    private TbAddress address;

}
