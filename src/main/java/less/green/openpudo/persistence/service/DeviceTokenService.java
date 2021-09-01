package less.green.openpudo.persistence.service;

import java.util.Date;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.persistence.dao.DeviceTokenDao;
import less.green.openpudo.persistence.model.TbDeviceToken;
import less.green.openpudo.rest.dto.user.DeviceToken;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class DeviceTokenService {

    @Inject
    DeviceTokenDao deviceTokenDao;

    public void upsertDeviceToken(Long userId, DeviceToken req, String applicationLanguage) {
        Date now = new Date();
        TbDeviceToken token = deviceTokenDao.get(req.getDeviceToken().trim());
        if (token == null) {
            // if not found, associate it with current user
            token = new TbDeviceToken();
            token.setDeviceToken(sanitizeString(req.getDeviceToken()));
            token.setUserId(userId);
            token.setCreateTms(now);
            token.setUpdateTms(now);
            token.setDeviceType(sanitizeString(req.getDeviceType()));
            token.setSystemName(sanitizeString(req.getSystemName()));
            token.setSystemVersion(sanitizeString(req.getSystemVersion()));
            token.setModel(sanitizeString(req.getModel()));
            token.setResolution(sanitizeString(req.getResolution()));
            token.setApplicationLanguage(applicationLanguage);
            token.setFailureCount(0);
            deviceTokenDao.persist(token);
            deviceTokenDao.flush();
        } else {
            if (!userId.equals(token.getUserId())) {
                // if associated with another user, recreate association
                token.setUserId(userId);
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
            token.setApplicationLanguage(applicationLanguage);
        }
    }

    public int removeFailedDeviceTokens() {
        return deviceTokenDao.removeFailedDeviceTokens();
    }

}
