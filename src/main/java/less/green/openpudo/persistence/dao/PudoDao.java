package less.green.openpudo.persistence.dao;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.projection.PudoAndAddress;
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

    public List<PudoAndAddress> searchPudo(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax) {
        String qs = "SELECT new less.green.openpudo.persistence.projection.PudoAndAddress(t1, t3) "
                + "FROM TbPudo t1, TbPudoAddress t2, TbAddress t3 "
                + "WHERE t1.pudoId = t2.pudoId AND t2.addressId = t3.addressId "
                + "AND t3.lat >= :latMin AND t3.lat <= :latMax "
                + "AND t3.lon >= :lonMin AND t3.lon <= :lonMax";
        TypedQuery<PudoAndAddress> q = em.createQuery(qs, PudoAndAddress.class);
        q.setParameter("latMin", latMin);
        q.setParameter("latMax", latMax);
        q.setParameter("lonMin", lonMin);
        q.setParameter("lonMax", lonMax);
        List<PudoAndAddress> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
