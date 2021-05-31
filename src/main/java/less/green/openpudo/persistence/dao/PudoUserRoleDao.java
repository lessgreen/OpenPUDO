package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbPudoUserRole;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PudoUserRoleDao {

    @PersistenceContext
    EntityManager em;

    public void flush() {
        em.flush();
    }

    public void persist(TbPudoUserRole ent) {
        em.persist(ent);
    }

}
