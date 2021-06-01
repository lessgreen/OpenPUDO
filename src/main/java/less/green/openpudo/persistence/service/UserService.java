package less.green.openpudo.persistence.service;

import java.util.Date;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.CryptoService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.dao.PudoDao;
import less.green.openpudo.persistence.dao.RelationDao;
import less.green.openpudo.persistence.dao.UserDao;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbPudoUserRole;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.rest.dto.auth.RegisterRequest;
import less.green.openpudo.rest.dto.user.User;

@RequestScoped
@Transactional
public class UserService {

    @Inject
    CryptoService cryptoService;

    @Inject
    AccountDao accountDao;
    @Inject
    UserDao userDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    RelationDao relationDao;

    public Long register(RegisterRequest req) {
        Date now = new Date();
        TbAccount account = new TbAccount();
        account.setCreateTms(now);
        account.setUpdateTms(now);
        account.setUsername(req.getUsername());
        account.setEmail(req.getEmail());
        account.setPhoneNumber(req.getPhoneNumber());
        AccountSecret secret = cryptoService.generateAccountSecret(req.getPassword());
        account.setSalt(secret.getSaltBase64());
        account.setPassword(secret.getPasswordHashBase64());
        account.setHashSpecs(secret.getHashSpecs());
        accountDao.persist(account);
        userDao.flush();
        TbUser user = new TbUser();
        user.setUserId(account.getUserId());
        user.setCreateTms(now);
        user.setUpdateTms(now);
        user.setFirstName(sanitizeString(req.getUser().getFirstName()));
        user.setLastName(sanitizeString(req.getUser().getLastName()));
        user.setSsn(sanitizeString(req.getUser().getSsn()));
        userDao.persist(user);
        userDao.flush();
        if (req.getPudo() != null) {
            TbPudo pudo = new TbPudo();
            pudo.setCreateTms(now);
            pudo.setUpdateTms(now);
            pudo.setBusinessName(sanitizeString(req.getPudo().getBusinessName()));
            pudo.setVat(sanitizeString(req.getPudo().getVat()));
            pudo.setPhoneNumber(req.getPudo().getPhoneNumber());
            pudo.setContactNotes(sanitizeString(req.getPudo().getContactNotes()));
            pudoDao.persist(pudo);
            pudoDao.flush();
            TbPudoUserRole role = new TbPudoUserRole();
            role.setUserId(account.getUserId());
            role.setPudoId(pudo.getPudoId());
            role.setCreateTms(now);
            role.setRoleType(RoleType.OWNER);
            relationDao.persist(role);
            relationDao.flush();
        }
        return account.getUserId();
    }

    public TbUser getUserById(Long userId) {
        return userDao.get(userId);
    }

    public TbUser updateUser(Long userId, User req) {
        Date now = new Date();
        TbUser user = userDao.get(userId);
        user.setUpdateTms(now);
        user.setFirstName(sanitizeString(req.getFirstName()));
        user.setLastName(sanitizeString(req.getLastName()));
        user.setSsn(sanitizeString(req.getSsn()));
        userDao.flush();
        return user;
    }

}
