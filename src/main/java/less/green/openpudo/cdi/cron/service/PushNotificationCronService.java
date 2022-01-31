package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.service.NotificationService;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
@Log4j2
public class PushNotificationCronService extends BaseCronService {

    private static final String NOTIFICATION_FAVOURITE_LOCK = "notification.favourite";

    @Inject
    NotificationService notificationService;

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void sendQueuedNotificationFavourite() {
        final UUID executionId = UUID.randomUUID();
        if (!acquireLock(executionId, NOTIFICATION_FAVOURITE_LOCK)) {
            return;
        }
        try {
            List<Long> rs = notificationService.getQueuedNotificationFavouriteIdsToSend();
            if (!rs.isEmpty()) {
                int sentCnt = 0;
                for (Long notificationId : rs) {
                    notificationService.sendQueuedNotificationFavourite(notificationId);
                    sentCnt++;

                    if (!refreshLock(executionId, NOTIFICATION_FAVOURITE_LOCK)) {
                        break;
                    }
                }
                log.info("[{}] Favourite notifications sent: {}/{}", executionId, sentCnt, rs.size());
            }
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(executionId, NOTIFICATION_FAVOURITE_LOCK);
        }
    }

}
