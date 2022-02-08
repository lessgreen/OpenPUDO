package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.service.PackageService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.List;

@ApplicationScoped
@Log4j2
public class PackageCronService extends BaseCronService {

    private static final String PACKAGE_NOTIFY_SENT_LOCK = "package.notify_sent";
    private static final String PACKAGE_ACCEPTED_LOCK = "package.accepted";
    private static final String PACKAGE_EXPIRED_LOCK = "package.expired";

    @Inject
    ExecutionContext context;

    @Inject
    PackageService packageService;

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void notifySentPackages() {
        if (!acquireLock(context.getExecutionId(), PACKAGE_NOTIFY_SENT_LOCK)) {
            return;
        }
        try {
            List<Long> rs = packageService.getPackageIdsToNotifySent();
            if (!rs.isEmpty()) {
                log.info("[{}] Moving packages in NOTIFY_SENT state", context.getExecutionId());
                for (var packageId : rs) {
                    packageService.notifySentPackage(packageId);

                    if (!refreshLock(context.getExecutionId(), PACKAGE_NOTIFY_SENT_LOCK)) {
                        return;
                    }
                }
                log.info("[{}] Packages NOTIFY_SENT: {}", context.getExecutionId(), rs.size());
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), PACKAGE_NOTIFY_SENT_LOCK);
        }
    }

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void acceptedPackages() {
        if (!acquireLock(context.getExecutionId(), PACKAGE_ACCEPTED_LOCK)) {
            return;
        }
        try {
            List<Long> rs = packageService.getPackageIdsToAccepted();
            if (!rs.isEmpty()) {
                log.info("[{}] Moving packages in ACCEPTED state", context.getExecutionId());
                for (var packageId : rs) {
                    packageService.autoAcceptedPackage(packageId);

                    if (!refreshLock(context.getExecutionId(), PACKAGE_ACCEPTED_LOCK)) {
                        return;
                    }
                }
                log.info("[{}] Packages ACCEPTED: {}", context.getExecutionId(), rs.size());
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), PACKAGE_ACCEPTED_LOCK);
        }
    }

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void expiredPackages() {
        if (!acquireLock(context.getExecutionId(), PACKAGE_EXPIRED_LOCK)) {
            return;
        }
        try {
            List<Long> rs = packageService.getPackageIdsToExpired();
            if (!rs.isEmpty()) {
                log.info("[{}] Moving packages in EXPIRED state", context.getExecutionId());
                for (var packageId : rs) {
                    packageService.expiredPackage(packageId);

                    if (!refreshLock(context.getExecutionId(), PACKAGE_EXPIRED_LOCK)) {
                        return;
                    }
                }
                log.info("[{}] Packages EXPIRED: {}", context.getExecutionId(), rs.size());
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), PACKAGE_EXPIRED_LOCK);
        }
    }

}
