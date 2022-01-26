package less.green.openpudo.business.service;

import io.quarkus.runtime.configuration.ProfileManager;
import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.OtpRequestType;
import less.green.openpudo.business.model.usertype.RelationType;
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
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.auth.RegisterCustomerRequest;
import less.green.openpudo.rest.dto.auth.RegisterPudoRequest;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class AuthService {

    private static final int LOGIN_ERROR_DELAY_MS = 1_000;

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    JwtService jwtService;
    @Inject
    SmsService smsService;

    @Inject
    PudoService pudoService;

    @Inject
    AddressDao addressDao;
    @Inject
    OtpRequestDao otpRequestDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    RatingDao ratingDao;
    @Inject
    RewardPolicyDao rewardPolicyDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPreferencesDao userPreferencesDao;
    @Inject
    UserProfileDao userProfileDao;
    @Inject
    UserPudoRelationDao userPudoRelationDao;

    @Inject
    DtoMapper dtoMapper;

    public void loginSend(String phoneNumber) {
        // searching for user
        TbUser user = userDao.getUserByPhoneNumber(phoneNumber);
        // if backdoor access for test user, simply pretend sending
        if ("dev".equals(ProfileManager.getActiveProfile()) || (user != null && user.getTestAccountFlag())) {
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
        // if backdoor access for test user, accept any otp
        if ("dev".equals(ProfileManager.getActiveProfile()) || (user != null && user.getTestAccountFlag())) {
            if (user == null) {
                // if user is a guest, we generate a short-lived token with phone number in private claims
                return jwtService.generateGuestTokenData(new JwtPrivateClaims(phoneNumber));
            } else {
                // is user is registered, we generate full access token
                user.setLastLoginTms(new Date());
                return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
            }
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
            user.setLastLoginTms(new Date());
            ret = jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
        }
        otpRequestDao.remove(otpRequest);
        otpRequestDao.flush();
        log.info("[{}] Login successful for {}", context.getExecutionId(), otpRequest.getRecipient());
        return ret;
    }

    public AccessTokenData registerCustomer(RegisterCustomerRequest req) {
        // searching for user
        TbUser user = userDao.getUserByPhoneNumber(context.getPrivateClaims().getPhoneNumber());
        if (user != null) {
            log.error("[{}] Register request for already registered user: {}", context.getExecutionId(), user.getUserId());
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.auth.already_registered"));
        }
        Date now = new Date();
        user = new TbUser();
        user.setCreateTms(now);
        user.setLastLoginTms(now);
        user.setAccountType(AccountType.CUSTOMER);
        user.setTestAccountFlag(false);
        // we trust the phone number contained in the signed private claims
        user.setPhoneNumber(context.getPrivateClaims().getPhoneNumber());
        userDao.persist(user);
        userDao.flush();
        TbUserProfile userProfile = new TbUserProfile();
        userProfile.setUserId(user.getUserId());
        userProfile.setCreateTms(now);
        userProfile.setUpdateTms(now);
        userProfile.setFirstName(sanitizeString(req.getUser().getFirstName()));
        userProfile.setLastName(sanitizeString(req.getUser().getLastName()));
        userProfile.setProfilePicId(null);
        userProfileDao.persist(userProfile);
        TbUserPreferences userPreferences = new TbUserPreferences();
        userPreferences.setUserId(user.getUserId());
        userPreferences.setCreateTms(now);
        userPreferences.setUpdateTms(now);
        userPreferences.setShowPhoneNumber(true);
        userPreferencesDao.persist(userPreferences);
        userPreferencesDao.flush();
        log.info("[{}] Registered user: {} as: {}", context.getExecutionId(), user.getUserId(), user.getAccountType());
        return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
    }

    public AccessTokenData registerPudo(RegisterPudoRequest req) {
        // searching for user
        TbUser user = userDao.getUserByPhoneNumber(context.getPrivateClaims().getPhoneNumber());
        if (user != null) {
            log.error("[{}] Register request for already registered user: {}", context.getExecutionId(), user.getUserId());
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.auth.already_registered"));
        }
        // deep validation of reward policy before persisting data
        TbRewardPolicy rewardPolicy = pudoService.mapRewardPolicyDtoToEntity(req.getRewardPolicy());

        Date now = new Date();
        user = new TbUser();
        user.setCreateTms(now);
        user.setLastLoginTms(now);
        user.setAccountType(AccountType.PUDO);
        user.setTestAccountFlag(false);
        // we trust the phone number contained in the signed private claims
        user.setPhoneNumber(context.getPrivateClaims().getPhoneNumber());
        userDao.persist(user);
        userDao.flush();
        TbPudo pudo = new TbPudo();
        pudo.setCreateTms(now);
        pudo.setUpdateTms(now);
        pudo.setBusinessName(sanitizeString(req.getPudo().getBusinessName()));
        pudo.setPublicPhoneNumber(sanitizeString(req.getPudo().getPublicPhoneNumber()));
        pudo.setPudoPicId(null);
        pudoDao.persist(pudo);
        pudoDao.flush();
        TbAddress address = dtoMapper.mapAddressMarkerToAddressEntity(req.getSignedAddressMarker().getAddress());
        address.setPudoId(pudo.getPudoId());
        address.setCreateTms(now);
        address.setUpdateTms(now);
        addressDao.persist(address);
        TbUserPudoRelation userPudoRelation = new TbUserPudoRelation();
        userPudoRelation.setUserId(user.getUserId());
        userPudoRelation.setPudoId(pudo.getPudoId());
        userPudoRelation.setCreateTms(now);
        userPudoRelation.setDeleteTms(null);
        userPudoRelation.setRelationType(RelationType.OWNER);
        userPudoRelation.setCustomerSuffix(null);
        userPudoRelationDao.persist(userPudoRelation);
        TbRating rating = new TbRating();
        rating.setPudoId(pudo.getPudoId());
        rating.setReviewCount(0L);
        rating.setAverageScore(null);
        ratingDao.persist(rating);
        rewardPolicy.setPudoId(pudo.getPudoId());
        rewardPolicy.setCreateTms(now);
        rewardPolicy.setDeleteTms(null);
        rewardPolicyDao.persist(rewardPolicy);
        pudoDao.flush();
        log.info("[{}] Registered user: {} as: {} with id: {}", context.getExecutionId(), user.getUserId(), user.getAccountType(), pudo.getPudoId());
        return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
    }

    public AccessTokenData renew() {
        TbUser user = userDao.get(context.getUserId());
        user.setLastLoginTms(new Date());
        return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
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
