package less.green.openpudo.persistence.service;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.rest.dto.DtoMapper;

@RequestScoped
@Transactional
public class AccountService {

    @Inject
    CryptoService cryptoService;

    @Inject
    AccountDao accountDao;

    @Inject
    DtoMapper dtoMapper;

    public TbAccount findAccountByLogin(String login) {
        return accountDao.findAccountByLogin(login);
    }

}
