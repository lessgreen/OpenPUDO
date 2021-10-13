package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbPudoAddress;
import less.green.openpudo.persistence.model.TbPudoUserRole;

import javax.enterprise.context.RequestScoped;
import javax.persistence.*;
import javax.transaction.Transactional;

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

    public Long getPudoIdByOwner(Long userId) {
        String qs = "SELECT t.pudoId FROM TbPudoUserRole t WHERE t.userId = :userId AND t.roleType = :roleType";
        try {
            TypedQuery<Long> q = em.createQuery(qs, Long.class);
            q.setParameter("userId", userId);
            q.setParameter("roleType", RoleType.OWNER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public boolean isPudoOwner(Long userId) {
        String qs = "SELECT COUNT(t) FROM TbPudoUserRole t WHERE t.userId = :userId AND t.roleType = :roleType";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        q.setParameter("roleType", RoleType.OWNER);
        long cnt = q.getSingleResult();
        return cnt > 0;
    }

    public boolean isPudoCustomer(Long userId, Long pudoId) {
        String qs = "SELECT COUNT(t) FROM TbPudoUserRole t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.roleType = :roleType";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        q.setParameter("pudoId", pudoId);
        q.setParameter("roleType", RoleType.CUSTOMER);
        long cnt = q.getSingleResult();
        return cnt > 0;
    }

    public int removePudoFromFavourites(Long userId, Long pudoId) {
        String qs = "DELETE FROM TbPudoUserRole t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.roleType = :roleType";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        q.setParameter("pudoId", pudoId);
        q.setParameter("roleType", RoleType.CUSTOMER);
        return q.executeUpdate();
    }

}
