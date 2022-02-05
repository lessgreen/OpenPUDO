package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.DeviceTokenDao;
import less.green.openpudo.business.dao.NotificationDao;
import less.green.openpudo.business.model.TbDeviceToken;
import less.green.openpudo.business.model.TbNotificationFavourite;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.FirebaseMessagingService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.rest.dto.DtoMapper;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
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

    public List<Long> getQueuedNotificationFavouriteIdsToSend() {
        return notificationDao.getQueuedNotificationFavouriteIdsToSend();
    }

    public void sendQueuedNotificationFavourite(Long notificationId) {
        TbNotificationFavourite notification = (TbNotificationFavourite) notificationDao.get(notificationId);
        Map<String, String> data = Map.of(
                "notificationId", notification.getNotificationId().toString(),
                "pudoId", notification.getPudoId().toString(),
                "userId", notification.getCustomerUserId().toString());
        sendPushNotifications(notification.getUserId(), notification.getTitle(), notification.getTitleParams(), notification.getMessage(), notification.getMessageParams(), data);
        notification.setQueuedFlag(false);
        notificationDao.flush();
    }

    public void sendPushNotifications(Long userId, String titleTemplate, String[] titleParams, String messageTemplate, String[] messageParams, Map<String, String> data) {
        List<TbDeviceToken> deviceTokens = deviceTokenDao.getDeviceTokens(userId);
        if (!deviceTokens.isEmpty()) {
            for (TbDeviceToken row : deviceTokens) {
                String title;
                if (titleParams == null || titleParams.length == 0) {
                    title = localizationService.getMessage(row.getApplicationLanguage(), titleTemplate);
                } else {
                    title = localizationService.getMessage(row.getApplicationLanguage(), titleTemplate, (Object[]) titleParams);
                }
                String message;
                if (messageParams == null || messageParams.length == 0) {
                    message = localizationService.getMessage(row.getApplicationLanguage(), messageTemplate);
                } else {
                    message = localizationService.getMessage(row.getApplicationLanguage(), messageTemplate, (Object[]) messageParams);
                }
                String messageId = firebaseMessagingService.sendNotification(row.getDeviceToken(), title, message, data);

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
