package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbUser;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class UserDao extends BaseEntityDao<TbUser, Long> {

    public UserDao() {
        super(TbUser.class, "user_id");
    }

}
