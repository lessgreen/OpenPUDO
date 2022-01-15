package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.user.DeviceToken;
import less.green.openpudo.rest.dto.user.UserPreferences;
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
    PackageDao packageDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPreferencesDao userPreferencesDao;
    @Inject
    UserProfileDao userProfileDao;

    @Inject
    DtoMapper dtoMapper;

    public UserProfile updateCurrentUserProfile(UserProfile req) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());
        userProfile.setUpdateTms(new Date());
        userProfile.setFirstName(sanitizeString(req.getFirstName()));
        userProfile.setLastName(sanitizeString(req.getLastName()));
        userProfileDao.flush();
        long packageCount = packageDao.getPackageCountForCustomer(context.getUserId());
        log.info("[{}] Updated profile for user: {}", context.getExecutionId(), context.getUserId());
        return dtoMapper.mapUserProfileEntityToDto(userProfile, user.getPhoneNumber(), null, packageCount);
    }

    public UUID updateCurrentUserProfilePic(String mimeType, byte[] bytes) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
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
        long packageCount = packageDao.getPackageCountForCustomer(context.getUserId());
        log.info("[{}] Updated profile picture for user: {}", context.getExecutionId(), context.getUserId());
        return newId;
    }

    public UserPreferences updateCurrentUserPreferences(UserPreferences req) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserPreferences userPreferences = userPreferencesDao.get(context.getUserId());
        userPreferences.setUpdateTms(new Date());
        userPreferences.setShowPhoneNumber(req.getShowPhoneNumber());
        userPreferencesDao.flush();
        log.info("[{}] Updated preferences for user: {}", context.getExecutionId(), context.getUserId());
        return dtoMapper.mapUserPreferencesEntityToDto(userPreferences);
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
