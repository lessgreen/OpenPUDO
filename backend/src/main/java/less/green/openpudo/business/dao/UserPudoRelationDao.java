package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUserPudoRelation;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.common.dto.tuple.Quintet;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.*;
import java.util.stream.Collectors;

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

    public Long getOwnerUserIdByPudoId(Long pudoId) {
        String qs = "SELECT t.userId FROM TbUserPudoRelation t WHERE t.pudoId = :pudoId AND t.relationType = :relationType AND t.deleteTms IS NULL";
        try {
            TypedQuery<Long> q = em.createQuery(qs, Long.class);
            q.setParameter("pudoId", pudoId);
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

    public TbUserPudoRelation getUserPudoActiveRelation(Long pudoId, Long userId) {
        String qs = "SELECT t FROM TbUserPudoRelation t WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.deleteTms IS NULL";
        try {
            TypedQuery<TbUserPudoRelation> q = em.createQuery(qs, TbUserPudoRelation.class);
            q.setParameter("userId", userId);
            q.setParameter("pudoId", pudoId);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public String getPastCustomerSuffix(Long pudoId, Long userId) {
        String qs = "SELECT DISTINCT(t.customerSuffix) FROM TbUserPudoRelation t "
                    + "WHERE t.userId = :userId AND t.pudoId = :pudoId AND t.relationType = :relationType AND t.deleteTms IS NOT NULL";
        try {
            TypedQuery<String> q = em.createQuery(qs, String.class);
            q.setParameter("userId", userId);
            q.setParameter("pudoId", pudoId);
            q.setParameter("relationType", RelationType.CUSTOMER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public Set<String> getCustomerSuffixesByPudoId(Long pudoId) {
        String qs = "SELECT DISTINCT(t.customerSuffix) FROM TbUserPudoRelation t WHERE t.pudoId = :pudoId AND t.relationType = :relationType";
        TypedQuery<String> q = em.createQuery(qs, String.class);
        q.setParameter("pudoId", pudoId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        List<String> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptySet() : new HashSet<>(rs);
    }

    public long getActiveCustomerCountByPudoId(Long pudoId) {
        String qs = "SELECT COUNT(*) FROM TbUserPudoRelation t WHERE t.pudoId = :pudoId AND t.relationType = :relationType AND t.deleteTms IS NULL";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("pudoId", pudoId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        return q.getSingleResult();
    }

    public List<Quintet<Long, String, String, UUID, String>> getActiveCustomersByPudoId(Long pudoId) {
        String qs = "SELECT t1.userId, t1.firstName, t1.lastName, t1.profilePicId, t2.customerSuffix "
                    + "FROM TbUserProfile t1, TbUserPudoRelation t2 "
                    + "WHERE t2.pudoId = :pudoId "
                    + "AND t2.userId = t1.userId "
                    + "AND t2.relationType = :relationType "
                    + "AND t2.deleteTms IS NULL "
                    + "ORDER BY t1.firstName, t1.lastName, t2.customerSuffix";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("pudoId", pudoId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Quintet<>((Long) row[0], (String) row[1], (String) row[2], (UUID) row[3], (String) row[4])).collect(Collectors.toList());
    }

}
