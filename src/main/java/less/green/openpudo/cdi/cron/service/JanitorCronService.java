package less.green.openpudo.cdi.cron.service;

import io.quarkus.scheduler.Scheduled;
import less.green.openpudo.business.service.JanitorService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ExceptionUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@ApplicationScoped
@Log4j2
public class JanitorCronService extends BaseCronService {

    private static final String JANITOR_DEVICE_TOKEN_LOCK = "janitor.device_token";
    private static final String JANITOR_OTP_REQUEST_LOCK = "janitor.otp_request";
    private static final String JANITOR_ORPHAN_FILES_LOCK = "janitor.orphan_files";

    @Inject
    ExecutionContext context;

    @Inject
    StorageService storageService;

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
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
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
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), JANITOR_DEVICE_TOKEN_LOCK);
        }
    }

    @Scheduled(cron = "0 0 1 * * ?", concurrentExecution = Scheduled.ConcurrentExecution.SKIP)
    void removeOrphanFiles() {
        if (!acquireLock(context.getExecutionId(), JANITOR_ORPHAN_FILES_LOCK)) {
            return;
        }
        try {
            Set<String> filesFromDb = janitorService.getAllStoredFiles();
            Set<String> filesFromStorage = storageService.getAllStoredFiles();
            var plusDb = filesFromDb.stream().filter(i -> !filesFromStorage.contains(i)).sorted().collect(Collectors.toList());
            var plusStorage = filesFromStorage.stream().filter(i -> !filesFromDb.contains(i)).sorted().collect(Collectors.toList());
            if (!plusDb.isEmpty()) {
                log.warn("[{}] Found {} files on DB that are not on storage: {}", context.getExecutionId(), plusDb.size(), plusDb);
            }
            if (!plusStorage.isEmpty()) {
                log.warn("[{}] Found {} files on storage that are not on DB: {}", context.getExecutionId(), plusStorage.size(), plusStorage);
                for (var file : plusStorage) {
                    storageService.deleteFile(UUID.fromString(file));
                    log.warn("[{}] Deleted orphan file: {}", context.getExecutionId(), file);
                }
            }
        } catch (Exception ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
        } finally {
            releaseLock(context.getExecutionId(), JANITOR_ORPHAN_FILES_LOCK);
        }
    }

}
