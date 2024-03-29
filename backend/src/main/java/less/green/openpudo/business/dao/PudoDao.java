package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.common.dto.tuple.Septet;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.Tuple;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
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

    public Quartet<TbPudo, TbAddress, TbRating, TbRewardPolicy> getPudo(Long pudoId) {
        String qs = "SELECT t1, t2, t3, t4 "
                    + "FROM TbPudo t1, TbAddress t2, TbRating t3, TbRewardPolicy t4 "
                    + "WHERE t1.pudoId = :pudoId AND t1.pudoId = t2.pudoId AND t1.pudoId = t3.pudoId AND t1.pudoId = t4.pudoId and t4.deleteTms IS NULL";
        try {
            TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
            q.setParameter("pudoId", pudoId);
            Object[] rs = q.getSingleResult();
            return new Quartet<>((TbPudo) rs[0], (TbAddress) rs[1], (TbRating) rs[2], (TbRewardPolicy) rs[3]);
        } catch (NoResultException ex) {
            return null;
        }
    }

    public List<Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal>> getPudosOnMap(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax) {
        String qs = "SELECT t1.pudoId, t1.businessName, t1.pudoPicId, t2.label, t3, t2.lat, t2.lon "
                    + "FROM TbPudo t1, TbAddress t2, TbRating t3 "
                    + "WHERE t1.pudoId = t2.pudoId AND t1.pudoId = t3.pudoId "
                    + "AND t2.lat >= :latMin AND t2.lat <= :latMax "
                    + "AND t2.lon >= :lonMin AND t2.lon <= :lonMax";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("latMin", latMin);
        q.setParameter("latMax", latMax);
        q.setParameter("lonMin", lonMin);
        q.setParameter("lonMax", lonMax);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Septet<>((Long) row[0], (String) row[1], (UUID) row[2], (String) row[3], (TbRating) row[4], (BigDecimal) row[5], (BigDecimal) row[6])).collect(Collectors.toList());
    }

    public List<Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal>> searchPudo(List<String> tokens) {
        String tsquery = tokens.stream().map(i -> i + ":*").collect(Collectors.joining(" | "));
        String qs = "SELECT t1.pudo_id, t1.business_name, CAST(t1.pudo_pic_id AS text), t2.label, t3.review_count, t3.average_score, t2.lat, t2.lon "
                    + "FROM tb_pudo t1, tb_address t2, tb_rating t3 "
                    + "WHERE t1.pudo_id = t2.pudo_id AND t1.pudo_id = t3.pudo_id "
                    + "AND t1.business_name_search @@ to_tsquery('simple', :tsquery)";
        Query q = em.createNativeQuery(qs, Tuple.class);
        q.setParameter("tsquery", tsquery);
        @SuppressWarnings("unchecked")
        List<Tuple> rs = q.getResultList();
        if (rs.isEmpty()) {
            return Collections.emptyList();
        }
        // map native query projection to match signature of other pudo search methods
        List<Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal>> ret = new ArrayList<>(rs.size());
        for (Tuple t : rs) {
            Septet<Long, String, UUID, String, TbRating, BigDecimal, BigDecimal> row = new Septet<>();
            row.setValue0(t.get("pudo_id", BigInteger.class).longValue());
            row.setValue1(t.get("business_name", String.class));
            row.setValue2(t.get("pudo_pic_id", String.class) == null ? null : UUID.fromString(t.get("pudo_pic_id", String.class)));
            row.setValue3(t.get("label", String.class));
            row.setValue4(new TbRating(t.get("pudo_id", BigInteger.class).longValue(), t.get("review_count", BigInteger.class).longValue(), t.get("average_score", BigDecimal.class)));
            row.setValue5(t.get("lat", BigDecimal.class));
            row.setValue6(t.get("lon", BigDecimal.class));
            ret.add(row);
        }
        return ret;
    }

    public List<Quartet<TbPudo, TbAddress, TbUserPudoRelation, TbRating>> getUserPudos(Long userId) {
        String qs = "SELECT t1, t2, t3, t4 "
                    + "FROM TbPudo t1, TbAddress t2, TbUserPudoRelation t3, TbRating t4 "
                    + "WHERE t1.pudoId = t2.pudoId AND t1.pudoId = t3.pudoId AND t1.pudoId = t4.pudoId "
                    + "AND t3.userId = :userId AND t3.relationType = :relationType AND t3.deleteTms IS NULL "
                    + "ORDER BY t3.createTms ASC";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("userId", userId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Quartet<>((TbPudo) row[0], (TbAddress) row[1], (TbUserPudoRelation) row[2], (TbRating) row[3])).collect(Collectors.toList());
    }

}
