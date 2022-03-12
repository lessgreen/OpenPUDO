package less.green.openpudo.cdi.cron.service;

import less.green.openpudo.business.service.CronLockService;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.inject.Inject;
import java.util.UUID;

@Log4j2
public abstract class BaseCronService {

    @Inject
    CronLockService cronLockService;

    protected boolean acquireLock(UUID executionId, String lockName) {
        try {
            return cronLockService.acquireLock(lockName);
        } catch (Exception ex) {
            log.fatal("[{}] {}", executionId, ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            return false;
        }
    }

    protected boolean refreshLock(UUID executionId, String lockName) {
        try {
            return cronLockService.refreshLock(lockName);
        } catch (Exception ex) {
            log.fatal("[{}] {}", executionId, ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            return false;
        }
    }

    protected boolean releaseLock(UUID executionId, String lockName) {
        try {
            return cronLockService.releaseLock(lockName);
        } catch (Exception ex) {
            log.fatal("[{}] {}", executionId, ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            return false;
        }
    }

}
