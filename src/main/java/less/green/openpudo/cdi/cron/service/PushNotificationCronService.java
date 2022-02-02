package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.service.NotificationService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.List;

@ApplicationScoped
@Log4j2
public class PushNotificationCronService extends BaseCronService {

    private static final String NOTIFICATION_FAVOURITE_LOCK = "notification.favourite";

    @Inject
    ExecutionContext context;

    @Inject
    NotificationService notificationService;

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void sendQueuedNotificationFavourite() {
        if (!acquireLock(context.getExecutionId(), NOTIFICATION_FAVOURITE_LOCK)) {
            return;
        }
        try {
            List<Long> rs = notificationService.getQueuedNotificationFavouriteIdsToSend();
            if (!rs.isEmpty()) {
                log.info("[{}] Sending favourite queued notifications", context.getExecutionId());
                for (Long notificationId : rs) {
                    notificationService.sendQueuedNotificationFavourite(notificationId);

                    if (!refreshLock(context.getExecutionId(), NOTIFICATION_FAVOURITE_LOCK)) {
                        return;
                    }
                }
                log.info("[{}] Favourite queued notifications sent: {}", context.getExecutionId(), rs.size());
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), NOTIFICATION_FAVOURITE_LOCK);
        }
    }

}
