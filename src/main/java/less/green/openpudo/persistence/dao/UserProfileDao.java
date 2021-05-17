package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbUserProfile;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class UserProfileDao extends BaseEntityDao<TbUserProfile, Long> {

    @PersistenceContext
    EntityManager em;

    public UserProfileDao() {
        super(TbUserProfile.class, "user_id");
    }

    @Override
    protected EntityManager getEntityManager() {
        return em;
    }

}
