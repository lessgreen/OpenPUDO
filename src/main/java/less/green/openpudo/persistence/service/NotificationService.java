package less.green.openpudo.persistence.service;

import java.util.Date;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.dao.NotificationDao;
import less.green.openpudo.persistence.model.TbNotification;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class NotificationService {

    @Inject
    NotificationDao notificationDao;

    public TbNotification getNotification(Long notificationId) {
        return notificationDao.get(notificationId);
    }

    public List<TbNotification> getNotificationList(Long userId, int limit, int offset) {
        return notificationDao.getNotificationList(userId, limit, offset);
    }

    public int markNotificationsAsRead(Long userId) {
        return notificationDao.markNotificationsAsRead(userId);
    }

    public void markNotificationAsRead(Long notificationId) {
        TbNotification notification = getNotification(notificationId);
        if (notification.getReadTms() != null) {
            return;
        }
        notification.setReadTms(new Date());
        notificationDao.flush();
    }

}
