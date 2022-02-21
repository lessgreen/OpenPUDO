package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.service.JanitorService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;

@ApplicationScoped
@Log4j2
public class JanitorCronService extends BaseCronService {

    private static final String JANITOR_DEVICE_TOKEN_LOCK = "janitor.device_token";
    private static final String JANITOR_OTP_REQUEST_LOCK = "janitor.otp_request";

    @Inject
    ExecutionContext context;

    @Inject
    JanitorService janitorService;

    @Scheduled(cron = "0 0 * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void removeExpiredOtpRequests() {
        if (!acquireLock(context.getExecutionId(), JANITOR_OTP_REQUEST_LOCK)) {
            return;
        }
        try {
            int cnt = janitorService.removeExpiredOtpRequests();
            if (cnt > 0) {
                log.info("[{}] Removed expired OTP requests: {}", context.getExecutionId(), cnt);
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), JANITOR_OTP_REQUEST_LOCK);
        }
    }

    @Scheduled(cron = "0 0 * * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void removeFailedDeviceTokens() {
        if (!acquireLock(context.getExecutionId(), JANITOR_DEVICE_TOKEN_LOCK)) {
            return;
        }
        try {
            int cnt = janitorService.removeFailedDeviceTokens();
            if (cnt > 0) {
                log.info("[{}] Removed failed device tokens: {}", context.getExecutionId(), cnt);
            }
        } catch (Exception ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), JANITOR_DEVICE_TOKEN_LOCK);
        }
    }

}
