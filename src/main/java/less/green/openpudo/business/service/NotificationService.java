package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.DeviceTokenDao;
import less.green.openpudo.business.dao.NotificationDao;
import less.green.openpudo.business.model.TbDeviceToken;
import less.green.openpudo.business.model.TbNotification;
import less.green.openpudo.business.model.TbNotificationFavourite;
import less.green.openpudo.business.model.TbNotificationPackage;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.FirebaseMessagingService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.notification.Notification;
import less.green.openpudo.rest.dto.notification.NotificationFavouriteOptData;
import less.green.openpudo.rest.dto.notification.NotificationOptData;
import less.green.openpudo.rest.dto.notification.NotificationPackageOptData;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class NotificationService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    FirebaseMessagingService firebaseMessagingService;

    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    NotificationDao notificationDao;

    @Inject
    DtoMapper dtoMapper;

    public List<Notification> getNotifications(int limit, int offset) {
        List<TbNotification> rs = notificationDao.getNotifications(context.getUserId(), limit, offset);
        List<Notification> ret = new ArrayList<>(rs.size());
        for (var row : rs) {
            NotificationOptData optData;
            if (row instanceof TbNotificationPackage) {
                optData = new NotificationPackageOptData(row.getNotificationId().toString(), ((TbNotificationPackage) row).getPackageId().toString());
            } else if (row instanceof TbNotificationFavourite) {
                optData = new NotificationFavouriteOptData(row.getNotificationId().toString(), ((TbNotificationFavourite) row).getCustomerUserId().toString(), ((TbNotificationFavourite) row).getPudoId().toString());
            } else {
                throw new AssertionError("Unsupported notification type: " + row.getClass());
            }
            String title = (row.getTitleParams() == null || row.getTitleParams().length == 0) ? localizationService.getMessage(context.getLanguage(), row.getTitle()) : localizationService.getMessage(context.getLanguage(), row.getTitle(), (Object[]) row.getTitleParams());
            String message = (row.getMessageParams() == null || row.getMessageParams().length == 0) ? localizationService.getMessage(context.getLanguage(), row.getMessage()) : localizationService.getMessage(context.getLanguage(), row.getMessage(), (Object[]) row.getMessageParams());
            ret.add(dtoMapper.mapNotificationDto(row, title, message, optData.toMap()));
        }
        return ret;
    }

    public long getUnreadNotificationCount() {
        return notificationDao.getUnreadNotificationCount(context.getUserId());
    }

    public void markNotificationsAsRead() {
        notificationDao.markNotificationsAsRead(context.getUserId());
    }

    public void markNotificationAsRead(Long notificationId) {
        TbNotification notification = notificationDao.get(notificationId);
        if (notification == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        if (!notification.getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }
        // if notification is read already, just return
        if (notification.getReadTms() != null) {
            return;
        }
        notification.setReadTms(new Date());
        notificationDao.flush();
    }

    public void deleteNotification(Long notificationId) {
        TbNotification notification = notificationDao.get(notificationId);
        if (notification == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        if (!notification.getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }
        notificationDao.remove(notification);
        notificationDao.flush();
    }

    public void deleteNotifications() {
        notificationDao.deleteNotifications(context.getUserId());
    }

    public List<Long> getQueuedNotificationFavouriteIdsToSend() {
        return notificationDao.getQueuedNotificationFavouriteIdsToSend();
    }

    public void sendQueuedNotificationFavourite(Long notificationId) {
        TbNotificationFavourite notification = (TbNotificationFavourite) notificationDao.get(notificationId);
        NotificationFavouriteOptData optData = new NotificationFavouriteOptData(notification.getNotificationId().toString(), notification.getCustomerUserId().toString(), notification.getPudoId().toString());
        sendPushNotifications(notification.getUserId(), notification.getTitle(), notification.getTitleParams(), notification.getMessage(), notification.getMessageParams(), optData.toMap());
        notification.setQueuedFlag(false);
        notificationDao.flush();
    }

    public void sendPushNotifications(Long userId, String titleTemplate, String[] titleParams, String messageTemplate, String[] messageParams, Map<String, String> data) {
        List<TbDeviceToken> deviceTokens = deviceTokenDao.getDeviceTokens(userId);
        if (!deviceTokens.isEmpty()) {
            for (TbDeviceToken row : deviceTokens) {
                String title = (titleParams == null || titleParams.length == 0) ? localizationService.getMessage(row.getApplicationLanguage(), titleTemplate) : localizationService.getMessage(row.getApplicationLanguage(), titleTemplate, (Object[]) titleParams);
                String message = (messageParams == null || messageParams.length == 0) ? localizationService.getMessage(row.getApplicationLanguage(), messageTemplate) : localizationService.getMessage(row.getApplicationLanguage(), messageTemplate, (Object[]) messageParams);
                String messageId;
                try {
                    messageId = firebaseMessagingService.sendNotification(row.getDeviceToken(), title, message, data);
                } catch (RuntimeException ex) {
                    log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
                    messageId = null;
                }
                Date now = new Date();
                row.setUpdateTms(now);
                if (messageId != null) {
                    row.setLastSuccessTms(now);
                    row.setLastSuccessMessageId(messageId);
                    row.setLastFailureTms(null);
                    row.setFailureCount(0);
                } else {
                    row.setLastFailureTms(now);
                    row.setFailureCount(row.getFailureCount() + 1);
                }
            }
            deviceTokenDao.flush();
        }
    }

}
