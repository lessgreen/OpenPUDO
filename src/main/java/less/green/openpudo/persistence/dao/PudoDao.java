package less.green.openpudo.persistence.dao;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.Tuple;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbAddress;
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

    public PudoAndAddress getPudoAndAddressById(Long pudoId) {
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

    public Long getPudoIdByOwnerUserId(Long userId) {
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

    public PudoAndAddress getPudoAndAddressByOwnerUserId(Long userId) {
        Long pudoId = getPudoIdByOwnerUserId(userId);
        if (pudoId == null) {
            return null;
        }
        return getPudoAndAddressById(pudoId);
    }

    public List<PudoAndAddress> searchPudo(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax, List<String> tokens) {
        if (tokens == null || tokens.isEmpty()) {
            // no full text needed, we can use JPQL
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
        } else {
            // full text needed, we must use native query
            String tsquery = tokens.stream().collect(Collectors.joining(" | "));
            String qs = "SELECT t1.pudo_id, t1.create_tms, t1.update_tms, t1.business_name, t1.vat, t1.phone_number, t1.contact_notes, "
                    + "t3.address_id, t3.create_tms create_tms2, t3.update_tms update_tms2, t3.street, t3.street_num, t3.zip_code, t3.city, t3.province, t3.country, t3.notes, t3.lat, t3.lon "
                    + "FROM tb_pudo t1, tb_pudo_address t2, tb_address t3 "
                    + "WHERE t1.pudo_id = t2.pudo_id AND t2.address_id = t3.address_id "
                    + "AND t3.lat >= :latMin AND t3.lat <= :latMax "
                    + "AND t3.lon >= :lonMin AND t3.lon <= :lonMax "
                    + "AND business_name_search @@ to_tsquery('simple', :tsquery)";
            Query q = em.createNativeQuery(qs, Tuple.class);
            q.setParameter("latMin", latMin);
            q.setParameter("latMax", latMax);
            q.setParameter("lonMin", lonMin);
            q.setParameter("lonMax", lonMax);
            q.setParameter("tsquery", tsquery);
            @SuppressWarnings("unchecked")
            List<Tuple> rs = q.getResultList();
            if (rs.isEmpty()) {
                return Collections.emptyList();
            }

            // map native resultset
            List<PudoAndAddress> ret = new ArrayList<>(rs.size());
            for (Tuple t : rs) {
                TbPudo pudo = new TbPudo();
                pudo.setPudoId(t.get("pudo_id", BigInteger.class).longValue());
                pudo.setCreateTms(t.get("create_tms", Date.class));
                pudo.setUpdateTms(t.get("update_tms", Date.class));
                pudo.setBusinessName(t.get("business_name", String.class));
                pudo.setVat(t.get("vat", String.class));
                pudo.setPhoneNumber(t.get("phone_number", String.class));
                pudo.setContactNotes(t.get("contact_notes", String.class));

                TbAddress address = new TbAddress();
                address.setAddressId(t.get("address_id", BigInteger.class).longValue());
                address.setCreateTms(t.get("create_tms2", Date.class));
                address.setUpdateTms(t.get("update_tms2", Date.class));
                address.setStreet(t.get("street", String.class));
                address.setStreetNum(t.get("street_num", String.class));
                address.setZipCode(t.get("zip_code", String.class));
                address.setCity(t.get("city", String.class));
                address.setProvince(t.get("province", String.class));
                address.setCountry(t.get("country", String.class));
                address.setNotes(t.get("notes", String.class));
                address.setLat(t.get("lat", BigDecimal.class));
                address.setLon(t.get("lon", BigDecimal.class));

                ret.add(new PudoAndAddress(pudo, address));
            }
            return ret;
        }
    }

}
