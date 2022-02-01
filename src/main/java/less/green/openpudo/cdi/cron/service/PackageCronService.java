package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.model.TbPackageEvent;
import less.green.openpudo.business.service.PackageService;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.List;
import java.util.UUID;

@ApplicationScoped
@Log4j2
public class PackageCronService extends BaseCronService {

    private static final String PACKAGE_NOTIFY_SENT_LOCK = "package.notify_sent";

    @Inject
    PackageService packageService;

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void notifySentPackages() {
        final UUID executionId = UUID.randomUUID();
        if (!acquireLock(executionId, PACKAGE_NOTIFY_SENT_LOCK)) {
            return;
        }
        try {
            List<Long> packageIds = packageService.getPackageIdsToNotifySent();
            for (var packageId : packageIds) {
                TbPackageEvent packageEvent = packageService.notifySentPackage(packageId);
                log.info("[{}] Package: {} -> {}", executionId, packageId, packageEvent.getPackageStatus());

                if (!refreshLock(executionId, PACKAGE_NOTIFY_SENT_LOCK)) {
                    return;
                }
            }
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(executionId, PACKAGE_NOTIFY_SENT_LOCK);
        }
    }

}
