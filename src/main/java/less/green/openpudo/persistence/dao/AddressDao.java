package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbAddress;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class AddressDao extends BaseEntityDao<TbAddress, Long> {

    @PersistenceContext
    EntityManager em;

    public AddressDao() {
        super(TbAddress.class, "address_id");
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

}
