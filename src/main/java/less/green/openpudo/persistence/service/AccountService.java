package less.green.openpudo.persistence.service;

import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.model.TbAccount;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;

@RequestScoped
@Transactional
public class AccountService {

    @Inject
    CryptoService cryptoService;

    @Inject
    AccountDao accountDao;

    public TbAccount getAccountByUserId(Long userId) {
        return accountDao.get(userId);
    }

    public TbAccount getAccountByLogin(String login) {
        return accountDao.getAccountByLogin(login);
    }

    public void changePassword(Long userId, String newPassword) {
        TbAccount account = getAccountByUserId(userId);
        account.setUpdateTms(new Date());
        AccountSecret secret = cryptoService.generateAccountSecret(newPassword);
        account.setSalt(secret.getSaltBase64());
        account.setPassword(secret.getPasswordHashBase64());
        account.setHashSpecs(secret.getHashSpecs());
        accountDao.flush();
    }

}
