package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.persistence.model.TbAccount;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class AccountDao extends BaseEntityDao<TbAccount, Long> {

    @PersistenceContext
    EntityManager em;

    public AccountDao() {
        super(TbAccount.class, "account_id");
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public TbAccount findAccountByLogin(String login) {
        if (isEmpty(login)) {
            return null;
        }
        String qs = "SELECT t FROM TbAccount t WHERE LOWER(t.username) = LOWER(:login) OR LOWER(t.email) = LOWER(:login) OR t.phoneNumber = :login";
        try {
            TypedQuery<TbAccount> q = em.createQuery(qs, TbAccount.class);
            q.setParameter("login", login);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
