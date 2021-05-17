package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbUserAddress;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class UserAddressDao {

    @PersistenceContext
    EntityManager em;

    public void flush() {
        em.flush();
    }

    public void persist(TbUserAddress ent) {
        em.persist(ent);
    }

}
