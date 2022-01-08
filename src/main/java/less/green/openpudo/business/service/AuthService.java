package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.OtpRequestDao;
import less.green.openpudo.business.dao.UserDao;
import less.green.openpudo.business.model.TbOtpRequest;
import less.green.openpudo.business.model.TbUser;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.OtpRequestType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.SmsService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.jwt.AccessProfile;
import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.common.dto.jwt.JwtPrivateClaims;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class AuthService {

    private static final int LOGIN_ERROR_DELAY_MS = 1_000;

    @Inject
    ExecutionContext context;

    @Inject
    JwtService jwtService;
    @Inject
    LocalizationService localizationService;

    @Inject
    SmsService smsService;

    @Inject
    OtpRequestDao otpRequestDao;
    @Inject
    UserDao userDao;

    public void loginSend(String phoneNumber) {
        // searching for user
        TbUser user = userDao.getUserByPhoneNumber(phoneNumber);
        // if backdoor access for test user, simply pretend
        if (user != null && user.getTestAccountFlag()) {
            return;
        }
        // searching for existing otp request
        TbOtpRequest otpRequest;
        if (user != null) {
            otpRequest = otpRequestDao.getOtpRequestByUserId(user.getUserId(), OtpRequestType.LOGIN);
        } else {
            otpRequest = otpRequestDao.getOtpRequestByPhoneNumber(phoneNumber, OtpRequestType.LOGIN);
        }
        if (otpRequest == null) {
            // if no request found, send message and create row
            String otp = Integer.toString(ThreadLocalRandom.current().nextInt(100_000, 1_000_000));
            sendOtpMessage(phoneNumber, otp, context.getLanguage());
            Date now = new Date();
            otpRequest = new TbOtpRequest();
            otpRequest.setRequestId(UUID.randomUUID());
            otpRequest.setCreateTms(now);
            otpRequest.setUpdateTms(now);
            otpRequest.setRequestType(OtpRequestType.LOGIN);
            if (user != null) {
                otpRequest.setUserId(user.getUserId());
            } else {
                otpRequest.setPhoneNumber(phoneNumber);
            }
            otpRequest.setOtp(otp);
            otpRequest.setSendCount(1);
            otpRequestDao.persist(otpRequest);
        } else {
            // if request found, and allowed retrying, send another message and extend lease
            if (otpRequest.getSendCount() >= 3) {
                log.error("[{}] Too many login send attempts for {}", context.getExecutionId(), otpRequest.getRecipient());
                delayFailureResponse();
                throw new ApiException(ApiReturnCodes.INVALID_OTP, localizationService.getMessage(context.getLanguage(), "error.otp.too_many_attempts"));
            }
            sendOtpMessage(phoneNumber, otpRequest.getOtp(), context.getLanguage());
            otpRequest.setUpdateTms(new Date());
            otpRequest.setSendCount(otpRequest.getSendCount() + 1);
        }
        otpRequestDao.flush();
        log.info("[{}] Sent login OTP for {}", context.getExecutionId(), otpRequest.getRecipient());
    }

    public AccessTokenData loginConfirm(String phoneNumber, String otp) {
        // searching for user
        TbUser user = userDao.getUserByPhoneNumber(phoneNumber);
        // if backdoor access for test user, check against a static otp
        if (user != null && user.getTestAccountFlag() && otp.equals("000000")) {
            return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
        }
        // searching for existing otp request
        TbOtpRequest otpRequest;
        if (user != null) {
            otpRequest = otpRequestDao.getOtpRequestByUserId(user.getUserId(), OtpRequestType.LOGIN);
        } else {
            otpRequest = otpRequestDao.getOtpRequestByPhoneNumber(phoneNumber, OtpRequestType.LOGIN);
        }
        // if no request found
        if (otpRequest == null) {
            log.error("[{}] Login confirm attempt without matching request for phoneNumber: {}", context.getExecutionId(), phoneNumber);
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_OTP, localizationService.getMessage(context.getLanguage(), "error.otp.invalid_otp"));
        }
        // if request found, but wrong code
        if (!otpRequest.getOtp().equals(otp)) {
            log.error("[{}] Login confirm attempt, wrong OTP for {}", context.getExecutionId(), otpRequest.getRecipient());
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_OTP, localizationService.getMessage(context.getLanguage(), "error.otp.invalid_otp"));
        }
        AccessTokenData ret;
        if (user == null) {
            // if user is a guest, we generate a short-lived token with phone number in private claims
            ret = jwtService.generateGuestTokenData(new JwtPrivateClaims(phoneNumber));
        } else {
            // is user is registered, we generate full access token
            ret = jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
            user.setLastLoginTms(new Date());
        }
        otpRequestDao.remove(otpRequest);
        otpRequestDao.flush();
        log.info("[{}] Login successful for {}", context.getExecutionId(), otpRequest.getRecipient());
        return ret;
    }

    private AccessProfile mapAccountTypeToAccessProfile(AccountType accountType) {
        switch (accountType) {
            case PUDO:
                return AccessProfile.PUDO;
            case CUSTOMER:
                return AccessProfile.CUSTOMER;
            default:
                throw new AssertionError("Unsupported mapping for AccountType: " + accountType);
        }
    }

    private void sendOtpMessage(String phoneNumber, String otp, String language) {
        String text = localizationService.getMessage(language, "message.otp", otp);
        try {
            smsService.sendSms(phoneNumber, text);
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getRelevantStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(language, "error.service_unavailable"));
        }
    }

    private void delayFailureResponse() {
        try {
            Thread.sleep(LOGIN_ERROR_DELAY_MS);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
        }
    }

}
