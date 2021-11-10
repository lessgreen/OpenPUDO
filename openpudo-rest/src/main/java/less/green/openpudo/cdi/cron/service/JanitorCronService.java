package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.persistence.service.AccountService;
import less.green.openpudo.persistence.service.DeviceTokenService;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.UUID;

@ApplicationScoped
@Log4j2
public class JanitorCronService extends BaseCronService {

    private static final String JANITOR_DEVICE_TOKEN_LOCK = "janitor.device_token";
    private static final String JANITOR_OTP_REQUEST_LOCK = "janitor.otp_request";

    @Inject
    AccountService accountService;
    @Inject
    DeviceTokenService deviceTokenService;

    @Scheduled(cron = "0 0 1 * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void removeFailedDeviceTokens() {
        final UUID executionId = UUID.randomUUID();
        if (!acquireLock(executionId, JANITOR_DEVICE_TOKEN_LOCK)) {
            return;
        }
        try {
            int cnt = deviceTokenService.removeFailedDeviceTokens();
            if (cnt > 0) {
                log.info("[{}] Removed {} failed device tokens", executionId, cnt);
            }
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
        } finally {
            releaseLock(executionId, JANITOR_DEVICE_TOKEN_LOCK);
        }
    }

    @Scheduled(cron = "0 * * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void removeExpiredOtpRequests() {
        final UUID executionId = UUID.randomUUID();
        if (!acquireLock(executionId, JANITOR_OTP_REQUEST_LOCK)) {
            return;
        }
        try {
            int cnt = accountService.removeExpiredOtpRequests();
            if (cnt > 0) {
                log.info("[{}] Removed {} expired OTP requests", executionId, cnt);
            }
        } catch (Exception ex) {
            log.error("[{}] {}", executionId, ExceptionUtils.getCompactStackTrace(ex));
        } finally {
            releaseLock(executionId, JANITOR_OTP_REQUEST_LOCK);
        }
    }

}