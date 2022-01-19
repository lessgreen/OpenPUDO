package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbAddress;
import less.green.openpudo.business.model.TbPudo;
import less.green.openpudo.business.model.TbRating;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.common.dto.tuple.Triplet;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class PudoDao extends BaseEntityDao<TbPudo, Long> {

    public PudoDao() {
        super(TbPudo.class, "pudoId");
    }

    public Triplet<TbPudo, TbAddress, TbRating> getPudoDeep(Long pudoId) {
        String qs = "SELECT t1, t2, t3 "
                + "FROM TbPudo t1, TbAddress t2, TbRating t3 "
                + "WHERE t1.pudoId = :pudoId AND t1.pudoId = t2.pudoId AND t1.pudoId = t3.pudoId";
        try {
            TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
            q.setParameter("pudoId", pudoId);
            Object[] rs = q.getSingleResult();
            return new Triplet<>((TbPudo) rs[0], (TbAddress) rs[1], (TbRating) rs[2]);
        } catch (NoResultException ex) {
            return null;
        }
    }

    public List<Triplet<Long, BigDecimal, BigDecimal>> getPudosOnMap(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax) {
        String qs = "SELECT t1.pudoId, t2.lat, t2.lon "
                + "FROM TbPudo t1, TbAddress t2 "
                + "WHERE t1.pudoId = t2.pudoId "
                + "AND t1.pudoPicId IS NOT NULL "
                + "AND t2.lat >= :latMin AND t2.lat <= :latMax "
                + "AND t2.lon >= :lonMin AND t2.lon <= :lonMax";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("latMin", latMin);
        q.setParameter("latMax", latMax);
        q.setParameter("lonMin", lonMin);
        q.setParameter("lonMax", lonMax);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Triplet<>((Long) row[0], (BigDecimal) row[1], (BigDecimal) row[2])).collect(Collectors.toList());
    }

    public List<Quartet<Long, String, UUID, String>> getCurrentUserPudos(Long userId) {
        String qs = "SELECT t1.pudoId, t1.businessName, t1.pudoPicId, t2.label "
                + "FROM TbPudo t1, TbAddress t2, TbUserPudoRelation t3 "
                + "WHERE t1.pudoId = t2.pudoId AND t1.pudoId = t3.pudoId "
                + "AND t3.userId = :userId AND t3.relationType = :relationType AND t3.deleteTms IS NULL "
                + "ORDER BY t1.pudoId";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("userId", userId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Quartet<>((Long) row[0], (String) row[1], (UUID) row[2], (String) row[3])).collect(Collectors.toList());
    }

}
