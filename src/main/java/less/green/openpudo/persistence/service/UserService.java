package less.green.openpudo.persistence.service;

import java.util.Date;
import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.StorageService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.dao.DeviceTokenDao;
import less.green.openpudo.persistence.dao.ExternalFileDao;
import less.green.openpudo.persistence.dao.PudoDao;
import less.green.openpudo.persistence.dao.RelationDao;
import less.green.openpudo.persistence.dao.UserDao;
import less.green.openpudo.persistence.dao.usertype.RoleType;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.persistence.model.TbDeviceToken;
import less.green.openpudo.persistence.model.TbExternalFile;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbPudoUserRole;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.rest.dto.auth.RegisterRequest;
import less.green.openpudo.rest.dto.user.User;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class UserService {

    @Inject
    CryptoService cryptoService;

    @Inject
    StorageService storageService;

    @Inject
    AccountDao accountDao;
    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    RelationDao relationDao;
    @Inject
    UserDao userDao;

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

    public TbUser updateUserProfilePic(Long userId, String mimeType, byte[] bytes) {
        Date now = new Date();
        TbUser user = userDao.get(userId);
        UUID oldId = user.getProfilePicId();
        UUID newId = UUID.randomUUID();
        // save new file first
        storageService.saveFileBinary(newId, bytes);
        // delete old file if any
        if (oldId != null) {
            storageService.deleteFile(oldId);
        }
        // if everything is ok, we can update database
        // save new row
        TbExternalFile ent = new TbExternalFile();
        ent.setExternalFileId(newId);
        ent.setCreateTms(now);
        ent.setMimeType(mimeType);
        externalFileDao.persist(ent);
        externalFileDao.flush();
        // switch foreign key
        user.setUpdateTms(now);
        user.setProfilePicId(newId);
        userDao.flush();
        externalFileDao.delete(oldId);
        externalFileDao.flush();
        return user;
    }

    public TbUser deleteUserProfilePic(Long userId) {
        Date now = new Date();
        TbUser user = userDao.get(userId);
        if (user.getProfilePicId() == null) {
            // nothing to do
            return user;
        }
        storageService.deleteFile(user.getProfilePicId());
        // if everything is ok, we can update database
        user.setUpdateTms(now);
        user.setProfilePicId(null);
        userDao.flush();
        return user;
    }

    public void upsertDeviceToken(Long userId, String deviceToken) {
        Date now = new Date();
        TbDeviceToken token = deviceTokenDao.get(deviceToken);
        if (token == null) {
            // if not found, associate it with current user
            token = new TbDeviceToken();
            token.setDeviceToken(deviceToken);
            token.setUserId(userId);
            token.setCreateTms(now);
            token.setLastAccessTms(now);
            deviceTokenDao.persist(token);
            deviceTokenDao.flush();
        } else {
            if (userId.equals(token.getUserId())) {
                // if found and associated with current user, update last access
                token.setLastAccessTms(now);
                deviceTokenDao.flush();
            } else {
                // if found and associated with another user, recreate association
                token.setUserId(userId);
                token.setCreateTms(now);
                token.setLastAccessTms(now);
                deviceTokenDao.flush();
            }
        }
    }

}
