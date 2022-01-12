package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.DeviceTokenDao;
import less.green.openpudo.business.dao.ExternalFileDao;
import less.green.openpudo.business.dao.UserDao;
import less.green.openpudo.business.dao.UserProfileDao;
import less.green.openpudo.business.model.TbDeviceToken;
import less.green.openpudo.business.model.TbExternalFile;
import less.green.openpudo.business.model.TbUser;
import less.green.openpudo.business.model.TbUserProfile;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.user.DeviceToken;
import less.green.openpudo.rest.dto.user.UserProfile;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;
import java.util.UUID;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class UserService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    StorageService storageService;

    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    UserDao userDao;
    @Inject
    UserProfileDao userProfileDao;

    @Inject
    DtoMapper dtoMapper;

    public UserProfile updateCurrentUserProfilePic(String mimeType, byte[] bytes) {
        Date now = new Date();
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());
        UUID oldId = userProfile.getProfilePicId();
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
        userProfile.setUpdateTms(now);
        userProfile.setProfilePicId(newId);
        userDao.flush();
        // remove old row
        externalFileDao.delete(oldId);
        externalFileDao.flush();
        // since the caller is the user itself, fill all optional fields
        TbUser user = userDao.get(context.getUserId());
        // TODO: get package count
        return dtoMapper.mapUserProfileEntityToDto(userProfile, user.getPhoneNumber(), 0);
    }

    public void upsertDeviceToken(DeviceToken req) {
        Date now = new Date();
        TbDeviceToken token = deviceTokenDao.get(req.getDeviceToken().trim());
        if (token == null) {
            // if not found, associate it with current user
            token = new TbDeviceToken();
            token.setDeviceToken(sanitizeString(req.getDeviceToken()));
            token.setUserId(context.getUserId());
            token.setCreateTms(now);
            token.setUpdateTms(now);
            token.setDeviceType(sanitizeString(req.getDeviceType()));
            token.setSystemName(sanitizeString(req.getSystemName()));
            token.setSystemVersion(sanitizeString(req.getSystemVersion()));
            token.setModel(sanitizeString(req.getModel()));
            token.setResolution(sanitizeString(req.getResolution()));
            token.setApplicationLanguage(context.getLanguage());
            token.setFailureCount(0);
            deviceTokenDao.persist(token);
        } else {
            if (!context.getUserId().equals(token.getUserId())) {
                // if associated with another user, recreate association
                token.setUserId(context.getUserId());
                token.setCreateTms(now);
                token.setLastSuccessTms(null);
                token.setLastSuccessMessageId(null);
                token.setLastFailureTms(null);
                token.setFailureCount(0);
            }
            token.setUpdateTms(now);
            token.setDeviceType(sanitizeString(req.getDeviceType()));
            token.setSystemName(sanitizeString(req.getSystemName()));
            token.setSystemVersion(sanitizeString(req.getSystemVersion()));
            token.setModel(sanitizeString(req.getModel()));
            token.setResolution(sanitizeString(req.getResolution()));
            token.setApplicationLanguage(context.getLanguage());
        }
        deviceTokenDao.flush();
    }

}
