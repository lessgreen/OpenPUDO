package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import java.util.List;
import java.util.UUID;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.persistence.service.PackageService;
import lombok.extern.log4j.Log4j2;

@ApplicationScoped
@Log4j2
public class PackageCronService extends BaseCronService {

    private static final String PACKAGE_NOIFY_SENT_LOCK = "package.notify_sent";

    @Inject
    PackageService packageService;

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void notifySentPackages() {
        final UUID executionId = UUID.randomUUID();
        if (!acquireLock(executionId, PACKAGE_NOIFY_SENT_LOCK)) {
            return;
        }
        try {
            List<Pair<TbPackage, List<TbPackageEvent>>> packs = packageService.getDeliveredPackageShallowList();
            for (Pair<TbPackage, List<TbPackageEvent>> pack : packs) {
                pack = packageService.notifySentPackage(pack.getValue0().getPackageId());
                log.info("[{}] Package: {} -> {}", executionId, pack.getValue0().getPackageId(), pack.getValue1().get(0).getPackageStatus());

                if (!refreshLock(executionId, PACKAGE_NOIFY_SENT_LOCK)) {
                    return;
                }
            }
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
        } finally {
            releaseLock(executionId, PACKAGE_NOIFY_SENT_LOCK);
        }
    }

}
