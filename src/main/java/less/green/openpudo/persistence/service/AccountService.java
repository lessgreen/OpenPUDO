package less.green.openpudo.persistence.service;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.model.TbAccount;

@RequestScoped
@Transactional
public class AccountService {

    @Inject
    AccountDao accountDao;

    public TbAccount findAccountByLogin(String login) {
        return accountDao.findAccountByLogin(login);
    }

}
