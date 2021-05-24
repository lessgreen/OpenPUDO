package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
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

    public boolean isPudoOwner(Long userId) {
        String qs = "SELECT COUNT(t) FROM TbPudoUserRole t WHERE t.userId = :userId AND t.roleType = :roleType";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        q.setParameter("roleType", RoleType.OWNER);
        Long cnt = q.getSingleResult();
        return cnt > 0;
    }

}
