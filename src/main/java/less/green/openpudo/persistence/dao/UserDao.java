package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.persistence.model.TbUser;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class UserDao extends BaseEntityDao<TbUser, Long> {

    @PersistenceContext
    EntityManager em;

    public UserDao() {
        super(TbUser.class, "user_id");
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

    public TbUser findUserByLogin(String login) {
        if (isEmpty(login)) {
            return null;
        }
        String qs = "SELECT t FROM TbUser t WHERE LOWER(t.username) = LOWER(:login) OR LOWER(t.email) = LOWER(:login) OR t.phoneNumber = :login";
        try {
            TypedQuery<TbUser> q = em.createQuery(qs, TbUser.class);
            q.setParameter("login", login);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
