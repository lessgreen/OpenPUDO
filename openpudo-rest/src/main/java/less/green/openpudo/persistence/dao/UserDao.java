package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.model.TbUser;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class UserDao extends BaseEntityDao<TbUser, Long> {

    public UserDao() {
        super(TbUser.class, "userId");
    }

}
