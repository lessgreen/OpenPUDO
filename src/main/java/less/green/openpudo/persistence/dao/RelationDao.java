package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbPudoAddress;
import less.green.openpudo.persistence.model.TbPudoUserRole;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class RelationDao {

    @PersistenceContext
    EntityManager em;

    public void flush() {
        em.flush();
    }

    public void persist(TbPudoUserRole ent) {
        em.persist(ent);
    }

    public void persist(TbPudoAddress ent) {
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

    public boolean isPudoCustomer(Long userId, Long pudoId) {
        String qs = "SELECT COUNT(t) FROM TbPudoUserRole t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.roleType = :roleType";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        q.setParameter("pudoId", pudoId);
        q.setParameter("roleType", RoleType.CUSTOMER);
        Long cnt = q.getSingleResult();
        return cnt > 0;
    }

    public int removePudoFromFavourites(Long userId, Long pudoId) {
        String qs = "DELETE FROM TbPudoUserRole t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.roleType = :roleType";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        q.setParameter("pudoId", pudoId);
        q.setParameter("roleType", RoleType.CUSTOMER);
        int cnt = q.executeUpdate();
        return cnt;
    }

}
