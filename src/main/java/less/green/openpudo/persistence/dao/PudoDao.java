package less.green.openpudo.persistence.dao;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
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

    public List<TbPudo> searchPudo(List<String> tokens) {
        String tsquery = tokens.stream().collect(Collectors.joining(" | "));
        String qs = "SELECT pudo_id, create_tms, update_tms, business_name, vat, phone_number, contact_notes\n"
                + "FROM (\n"
                + "SELECT pudo_id, create_tms, update_tms, business_name, vat, phone_number, contact_notes, ts_rank_cd(business_name_search, to_tsquery('simple', :tsquery)) rank\n"
                + "FROM tb_pudo\n"
                + "WHERE business_name_search @@ to_tsquery('simple', :tsquery)\n"
                + "ORDER BY rank DESC\n"
                + ") q1";
        Query q = em.createNativeQuery(qs, TbPudo.class);
        q.setParameter("tsquery", tsquery);
        @SuppressWarnings("unchecked")
        List<TbPudo> resultList = q.getResultList();
        return resultList.isEmpty() ? Collections.emptyList() : resultList;
    }

}
