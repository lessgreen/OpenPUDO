package less.green.openpudo.persistence.service;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.EmailService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.SmsService;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.persistence.dao.AccountDao;
import less.green.openpudo.persistence.dao.OtpRequestDao;
import less.green.openpudo.persistence.dao.UserDao;
import less.green.openpudo.persistence.dao.usertype.OtpRequestType;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.persistence.model.TbOtpRequest;
import less.green.openpudo.persistence.model.TbUser;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Transactional
@Log4j2
public class AccountService {

    @Inject
    ExecutionContext context;

    @Inject
    CryptoService cryptoService;
    @Inject
    EmailService emailService;
    @Inject
    SmsService smsService;
    @Inject
    LocalizationService localizationService;

    @Inject
    AccountDao accountDao;
    @Inject
    OtpRequestDao otpRequestDao;
    @Inject
    UserDao userDao;

    public TbAccount getAccountByUserId(Long userId) {
        return accountDao.get(userId);
    }

    public TbAccount getAccountByLogin(String login) {
        return accountDao.getAccountByLogin(login);
    }

    public void changePassword(Long userId, String newPassword) {
        TbAccount account = getAccountByUserId(userId);
        account.setUpdateTms(new Date());
        AccountSecret secret = cryptoService.generateAccountSecret(newPassword);
        account.setSalt(secret.getSaltBase64());
        account.setPassword(secret.getPasswordHashBase64());
        account.setHashSpecs(secret.getHashSpecs());
        accountDao.flush();
    }

    public TbOtpRequest getOtpRequestByUserIdAndRequestType(Long userId, OtpRequestType requestType) {
        return otpRequestDao.getOtpRequestByUserIdAndRequestType(userId, requestType);
    }

    public void resetPassword(Long userId, String language) {
        TbAccount account = getAccountByUserId(userId);
        TbUser user = userDao.get(userId);
        TbOtpRequest otpRequest = getOtpRequestByUserIdAndRequestType(userId, OtpRequestType.RESET_PASSWORD);
        if (otpRequest == null) {
            // if no request found, send message and create row
            String otp = Integer.toString(ThreadLocalRandom.current().nextInt(100_000, 1_000_000));
            boolean success = sendOtpMessage(account, user, language, otp);
            // if send failed, no row is persisted
            if (!success) {
                return;
            }
            Date now = new Date();
            otpRequest = new TbOtpRequest();
            otpRequest.setRequestId(UUID.randomUUID());
            otpRequest.setUserId(userId);
            otpRequest.setCreateTms(now);
            otpRequest.setUpdateTms(now);
            otpRequest.setRequestType(OtpRequestType.RESET_PASSWORD);
            otpRequest.setOtp(otp);
            otpRequest.setRetryCount(1);
            otpRequestDao.persist(otpRequest);
        } else {
            // if request found, and allowed retrying, extend lease and send another message
            if (otpRequest.getRetryCount() >= 3) {
                log.error("[{}] Too many reset password retry for request: {}", context.getExecutionId(), otpRequest.getRequestId());
                return;
            }
            boolean success = sendOtpMessage(account, user, language, otpRequest.getOtp());
            // if send failed, retryCount is not incremented
            if (!success) {
                return;
            }
            otpRequest.setRetryCount(otpRequest.getRetryCount() + 1);
        }
        otpRequestDao.flush();
    }

    public void confirmResetPassword(Long userId, String newPassword, UUID requestId) {
        changePassword(userId, newPassword);
        otpRequestDao.delete(requestId);
        otpRequestDao.flush();
    }

    private boolean sendOtpMessage(TbAccount account, TbUser user, String language, String otp) {
        String fullName = user.getFirstName() + " " + user.getLastName();
        String email = account.getEmail();
        String phoneNumber = account.getPhoneNumber();
        String subject = localizationService.getMessage(language, "message.auth.reset_password.subject");
        String text = localizationService.getMessage(language, "message.auth.reset_password.text", otp);

        // if we have both contacts, try both channels but return success if at least one channel was successful
        RuntimeException emailException = null, smsException = null;
        if (!isEmpty(email)) {
            try {
                emailService.sendEmail(fullName, email, subject, text);
            } catch (RuntimeException ex) {
                log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
                emailException = ex;
            }
        }
        if (!isEmpty(phoneNumber)) {
            try {
                smsService.sendSms(phoneNumber, text);
            } catch (RuntimeException ex) {
                log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
                smsException = ex;
            }
        }
        return emailException == null && smsException == null;
    }

}
