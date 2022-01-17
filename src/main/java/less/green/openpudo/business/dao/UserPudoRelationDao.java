package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUserPudoRelation;
import less.green.openpudo.business.model.usertype.RelationType;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class UserPudoRelationDao extends BaseEntityDao<TbUserPudoRelation, Long> {

    public UserPudoRelationDao() {
        super(TbUserPudoRelation.class, "userPudoRelationId");
    }

    public Long getPudoIdByOwnerUserId(Long userId) {
        String qs = "SELECT t.pudoId FROM TbUserPudoRelation t WHERE t.userId = :userId AND t.relationType = :relationType AND t.deleteTms IS NULL";
        try {
            TypedQuery<Long> q = em.createQuery(qs, Long.class);
            q.setParameter("userId", userId);
            q.setParameter("relationType", RelationType.OWNER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public TbUserPudoRelation getUserPudoActiveCustomerRelation(Long pudoId, Long userId) {
        String qs = "SELECT t FROM TbUserPudoRelation t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.relationType = :relationType AND t.deleteTms IS NULL";
        try {
            TypedQuery<TbUserPudoRelation> q = em.createQuery(qs, TbUserPudoRelation.class);
            q.setParameter("userId", userId);
            q.setParameter("pudoId", pudoId);
            q.setParameter("relationType", RelationType.CUSTOMER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
