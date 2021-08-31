package less.green.openpudo.cdi.cron.service;

import java.util.UUID;
import javax.inject.Inject;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.persistence.service.CronLockService;
import lombok.extern.log4j.Log4j2;

@Log4j2
public class BaseCronService {

    @Inject
    CronLockService cronLockService;

    protected boolean acquireLock(UUID executionId, String lockName) {
        try {
            return cronLockService.acquireLock(lockName);
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
            return false;
        }
    }

    protected boolean refreshLock(UUID executionId, String lockName) {
        try {
            return cronLockService.refreshLock(lockName);
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
            return false;
        }
    }

    protected boolean releaseLock(UUID executionId, String lockName) {
        try {
            return cronLockService.releaseLock(lockName);
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
            return false;
        }
    }

}
