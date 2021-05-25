package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbPudo;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PudoDao extends BaseEntityDao<TbPudo, Long> {

    public PudoDao() {
        super(TbPudo.class, "pudo_id");
    }

    public TbPudo getPudoByOwnerUserId(Long userId) {
        String qs = "SELECT t1 FROM TbPudo t1, TbPudoUserRole t2 WHERE t1.pudoId = t2.pudoId AND t2.userId = :userId AND t2.roleType = :roleType";
        try {
            TypedQuery<TbPudo> q = em.createQuery(qs, TbPudo.class);
            q.setParameter("userId", userId);
            q.setParameter("roleType", RoleType.OWNER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
