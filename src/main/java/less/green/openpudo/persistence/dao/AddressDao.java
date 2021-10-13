package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.model.TbAddress;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class AddressDao extends BaseEntityDao<TbAddress, Long> {

    public AddressDao() {
        super(TbAddress.class, "addressId");
    }

}
