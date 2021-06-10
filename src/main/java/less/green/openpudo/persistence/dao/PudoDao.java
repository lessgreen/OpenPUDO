package less.green.openpudo.persistence.dao;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.Tuple;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.rest.dto.map.PudoMarker;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class PudoDao extends BaseEntityDao<TbPudo, Long> {

    public PudoDao() {
        super(TbPudo.class, "pudo_id");
    }

    public PudoAndAddress getPudoById(Long pudoId) {
        String qs = "SELECT new less.green.openpudo.persistence.projection.PudoAndAddress(t1, t3) "
                + "FROM TbPudo t1 LEFT JOIN TbPudoAddress t2 ON t1.pudoId = t2.pudoId "
                + "LEFT JOIN TbAddress t3 ON t2.addressId = t3.addressId "
                + "WHERE t1.pudoId = :pudoId";
        try {
            TypedQuery<PudoAndAddress> q = em.createQuery(qs, PudoAndAddress.class);
            q.setParameter("pudoId", pudoId);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public PudoAndAddress getPudoByOwner(Long userId) {
        String qs = "SELECT new less.green.openpudo.persistence.projection.PudoAndAddress(t1, t3) "
                + "FROM TbPudo t1 LEFT JOIN TbPudoAddress t2 ON t1.pudoId = t2.pudoId "
                + "LEFT JOIN TbAddress t3 ON t2.addressId = t3.addressId "
                + "WHERE EXISTS (SELECT t4 FROM TbPudoUserRole t4 "
                + "WHERE t4.pudoId = t1.pudoId AND t4.userId = :userId AND t4.roleType = :roleType)";
        try {
            TypedQuery<PudoAndAddress> q = em.createQuery(qs, PudoAndAddress.class);
            q.setParameter("userId", userId);
            q.setParameter("roleType", RoleType.OWNER);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public List<PudoAndAddress> getPudoListByCustomer(Long userId) {
        String qs = "SELECT new less.green.openpudo.persistence.projection.PudoAndAddress(t1, t3) "
                + "FROM TbPudo t1 LEFT JOIN TbPudoAddress t2 ON t1.pudoId = t2.pudoId "
                + "LEFT JOIN TbAddress t3 ON t2.addressId = t3.addressId "
                + "WHERE EXISTS (SELECT t4 FROM TbPudoUserRole t4 "
                + "WHERE t4.pudoId = t1.pudoId AND t4.userId = :userId AND t4.roleType = :roleType)";
        TypedQuery<PudoAndAddress> q = em.createQuery(qs, PudoAndAddress.class);
        q.setParameter("userId", userId);
        q.setParameter("roleType", RoleType.CUSTOMER);
        return q.getResultList();
    }

    public List<PudoMarker> searchPudosByCoordinates(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax) {
        String qs = "SELECT new less.green.openpudo.rest.dto.map.PudoMarker(t1.pudoId, t1.businessName, t3.label, t3.lat, t3.lon) "
                + "FROM TbPudo t1, TbPudoAddress t2, TbAddress t3 "
                + "WHERE t1.pudoId = t2.pudoId AND t2.addressId = t3.addressId "
                + "AND t3.lat >= :latMin AND t3.lat <= :latMax "
                + "AND t3.lon >= :lonMin AND t3.lon <= :lonMax";
        TypedQuery<PudoMarker> q = em.createQuery(qs, PudoMarker.class);
        q.setParameter("latMin", latMin);
        q.setParameter("latMax", latMax);
        q.setParameter("lonMin", lonMin);
        q.setParameter("lonMax", lonMax);
        List<PudoMarker> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public List<PudoMarker> searchPudosByName(List<String> tokens) {
        String tsquery = tokens.stream().map(i -> i + ":*").collect(Collectors.joining(" | "));
        String qs = "SELECT t1.pudo_id, t1.business_name, t3.label, t3.lat, t3.lon "
                + "FROM tb_pudo t1, tb_pudo_address t2, tb_address t3 "
                + "WHERE t1.pudo_id = t2.pudo_id AND t2.address_id = t3.address_id "
                + "AND business_name_search @@ to_tsquery('simple', :tsquery)";
        Query q = em.createNativeQuery(qs, Tuple.class);
        q.setParameter("tsquery", tsquery);
        @SuppressWarnings("unchecked")
        List<Tuple> rs = q.getResultList();
        if (rs.isEmpty()) {
            return Collections.emptyList();
        }
        // map native resultset
        List<PudoMarker> ret = new ArrayList<>(rs.size());
        for (Tuple t : rs) {
            PudoMarker marker = new PudoMarker();
            marker.setPudoId(t.get("pudo_id", BigInteger.class).longValue());
            marker.setBusinessName(t.get("business_name", String.class));
            marker.setLabel(t.get("label", String.class));
            marker.setLat(t.get("lat", BigDecimal.class));
            marker.setLon(t.get("lon", BigDecimal.class));
            ret.add(marker);
        }
        return ret;
    }

}
