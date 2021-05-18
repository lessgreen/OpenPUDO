package less.green.openpudo.persistence.service;

import java.util.Date;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.CryptoService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.UserSecret;
import less.green.openpudo.persistence.dao.UserDao;
import less.green.openpudo.persistence.dao.UserProfileDao;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.model.TbUserProfile;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.auth.RegisterRequest;

@RequestScoped
@Transactional
public class UserService {

    @Inject
    DtoMapper dtoMapper;

    @Inject
    CryptoService cryptoService;

    @Inject
    UserDao userDao;
    @Inject
    UserProfileDao userProfileDao;

    public TbUser createUser(RegisterRequest req) {
        Date now = new Date();
        TbUser user = new TbUser();
        user.setCreateTms(now);
        user.setUpdateTms(now);
        user.setUsername(req.getUsername());
        user.setEmail(req.getEmail());
        user.setPhoneNumber(req.getPhoneNumber());
        UserSecret secret = cryptoService.generateUserSecret(req.getPassword());
        user.setSalt(secret.getSaltBase64());
        user.setPassword(secret.getPasswordHashBase64());
        user.setHashSpecs(secret.getHashSpecs());
        userDao.persist(user);
        userDao.flush();
        TbUserProfile userProfile = new TbUserProfile();
        userProfile.setUserId(user.getUserId());
        userProfile.setCreateTms(now);
        userProfile.setUpdateTms(now);
        userProfile.setFirstName(sanitizeString(req.getUserProfile().getFirstName()));
        userProfile.setLastName(sanitizeString(req.getUserProfile().getLastName()));
        userProfile.setSsn(sanitizeString(req.getUserProfile().getSsn()));
        userProfileDao.persist(userProfile);
        userProfileDao.flush();
        return user;
    }

    public TbUser findUserByLogin(String login) {
        return userDao.findUserByLogin(login);
    }

}
