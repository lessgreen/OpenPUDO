package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUser;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class UserDao extends BaseEntityDao<TbUser, Long> {

    public UserDao() {
        super(TbUser.class, "userId");
    }

    public TbUser getUserByPhoneNumber(String phoneNumber) {
        if (isEmpty(phoneNumber)) {
            return null;
        }
        String qs = "SELECT t FROM TbUser t WHERE t.phoneNumber = :phoneNumber";
        try {
            TypedQuery<TbUser> q = em.createQuery(qs, TbUser.class);
            q.setParameter("phoneNumber", phoneNumber);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
