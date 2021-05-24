package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;
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

}
