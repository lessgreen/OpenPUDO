package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbAddress;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class AddressDao extends BaseEntityDao<TbAddress, Long> {

    public AddressDao() {
        super(TbAddress.class, "pudoId");
    }

}
