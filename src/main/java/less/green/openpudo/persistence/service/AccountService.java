package less.green.openpudo.persistence.service;

import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.model.TbAccount;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;

@RequestScoped
@Transactional
public class AccountService {

    @Inject
    AccountDao accountDao;

    public TbAccount findAccountByLogin(String login) {
        return accountDao.findAccountByLogin(login);
    }

}
