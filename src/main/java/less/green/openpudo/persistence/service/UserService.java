package less.green.openpudo.persistence.service;

import java.util.Date;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.CryptoService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.UserSecret;
import less.green.openpudo.persistence.dao.AddressDao;
import less.green.openpudo.persistence.dao.UserAddressDao;
import less.green.openpudo.persistence.dao.UserDao;
import less.green.openpudo.persistence.dao.UserProfileDao;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.model.TbUserAddress;
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
    @Inject
    AddressDao addressDao;
    @Inject
    UserAddressDao userAddressDao;

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
        TbAddress address = new TbAddress();
        address.setCreateTms(now);
        address.setUpdateTms(now);
        address.setStreet(sanitizeString(req.getAddress().getStreet()));
        address.setStreetNum(sanitizeString(req.getAddress().getStreetNum()));
        address.setZipCode(sanitizeString(req.getAddress().getZipCode()));
        address.setCity(sanitizeString(req.getAddress().getCity()));
        address.setProvince(sanitizeString(req.getAddress().getProvince()));
        address.setCountry(sanitizeString(req.getAddress().getCountry()));
        address.setNotes(sanitizeString(req.getAddress().getNotes()));
        address.setLat(req.getAddress().getLat());
        address.setLon(req.getAddress().getLon());
        addressDao.persist(address);
        addressDao.flush();
        TbUserAddress userAddress = new TbUserAddress();
        userAddress.setUserId(user.getUserId());
        userAddress.setAddressId(address.getAddressId());
        userAddressDao.persist(userAddress);
        userAddressDao.flush();
        return user;
    }

    public TbUser findUserByLogin(String login) {
        return userDao.findUserByLogin(login);
    }

}
