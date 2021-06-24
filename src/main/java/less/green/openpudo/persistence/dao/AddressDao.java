package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbAddress;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class AddressDao extends BaseEntityDao<TbAddress, Long> {

    public AddressDao() {
        super(TbAddress.class, "addressId");
    }

}
