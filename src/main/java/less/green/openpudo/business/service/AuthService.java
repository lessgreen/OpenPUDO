package less.green.openpudo.business.service;

import io.quarkus.runtime.configuration.ProfileManager;
import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.OtpRequestType;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.*;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.jwt.AccessProfile;
import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.common.dto.jwt.JwtPrivateClaims;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.auth.RegisterCustomerRequest;
import less.green.openpudo.rest.dto.auth.RegisterPudoRequest;
import less.green.openpudo.rest.dto.auth.SupportRequest;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class AuthService {

    private static final int LOGIN_ERROR_DELAY_MS = 1_000;

    @ConfigProperty(name = "app.base.url")
    String appBaseUrl;
    @ConfigProperty(name = "auth.backdoor", defaultValue = "false")
    Boolean authBackdoor;

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    CryptoService cryptoService;
    @Inject
    EmailService emailService;
    @Inject
    JwtService jwtService;
    @Inject
    SmsService smsService;

    @Inject
    PudoService pudoService;

    @Inject
    AddressDao addressDao;
    @Inject
    DeletedUserDataDao deletedUserDataDao;
    @Inject
    OtpRequestDao otpRequestDao;
    @Inject
    PackageDao packageDao;
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
        if ("dev".equals(ProfileManager.getActiveProfile()) || (authBackdoor && phoneNumber.matches("\\+393280000\\d{2}")) || (user != null && user.getTestAccountFlag())) {
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
            sendOtpMessage(phoneNumber, otp);
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
            sendOtpMessage(phoneNumber, otpRequest.getOtp());
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
        if ("dev".equals(ProfileManager.getActiveProfile()) || (authBackdoor && phoneNumber.matches("\\+393280000\\d{2}")) || (user != null && user.getTestAccountFlag())) {
            if (user == null) {
                // if user is a guest, we generate a short-lived token with phone number in private claims
                return jwtService.generateGuestTokenData(new JwtPrivateClaims(phoneNumber));
            } else {
                // fs user is registered, we generate full access token
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
        user.setTestAccountFlag(authBackdoor && context.getPrivateClaims().getPhoneNumber().matches("\\+393280000\\d{2}"));
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
        user.setTestAccountFlag(authBackdoor && context.getPrivateClaims().getPhoneNumber().matches("\\+393280000\\d{2}"));
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
        TbAddress address = dtoMapper.mapAddressEntity(req.getAddressMarker().getAddress());
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
        if (user == null) {
            throw new ApiException(ApiReturnCodes.EXPIRED_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.expired_access_token"));
        }
        user.setLastLoginTms(new Date());
        return jwtService.generateUserTokenData(user.getUserId(), mapAccountTypeToAccessProfile(user.getAccountType()));
    }

    public void supportRequest(SupportRequest req) {
        TbUser user = userDao.get(context.getUserId());
        String subject = String.format("Support request from user: %s (phone: %s)", context.getUserId(), user.getPhoneNumber());
        emailService.sendSupportEmail(subject, req.getMessage().trim());
        log.info("[{}] Sent support request for user: {}", context.getExecutionId(), context.getUserId());
    }

    public String deleteCurrentAccount() {
        TbUser user = userDao.get(context.getUserId());
        if (user == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        log.info("[{}] Deleting user: {}", context.getExecutionId(), context.getUserId());
        String phoneNumber = user.getPhoneNumber();
        String userData = getUserData(user);
        TbDeletedUserData deletedUserData = new TbDeletedUserData();
        deletedUserData.setUserDataId(UUID.randomUUID());
        deletedUserData.setCreateTms(new Date());
        deletedUserData.setUserData(userData);
        deletedUserDataDao.persist(deletedUserData);
        deletedUserDataDao.flush();
        String downloadUrl = appBaseUrl + "/api/v2/file/user-data/" + deletedUserData.getUserDataId().toString();
        // skip actual delete for test accounts
        if (!user.getTestAccountFlag()) {
            List<Pair<String, Integer>> rs = userDao.deleteUser(context.getUserId(), user.getAccountType() == AccountType.CUSTOMER ? null : pudoService.getCurrentPudoId());
            rs.forEach(i -> log.info("[{}] Deleted rows from {}: {}", context.getExecutionId(), i.getValue0(), i.getValue1()));
            try {
                smsService.sendSms(phoneNumber, localizationService.getMessage(context.getLanguage(), "message.delete-account", downloadUrl));
            } catch (RuntimeException ex) {
                log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
                throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
            }
            log.info("[{}] Deleted user: {}", context.getExecutionId(), context.getUserId());
        }
        return downloadUrl;
    }

    private String getUserData(TbUser user) {
        StringBuilder sb = new StringBuilder();
        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");
        sb.append("Phone number: ").append(user.getPhoneNumber()).append("\r\n");
        sb.append("Registered at: ").append(sdf.format(user.getCreateTms())).append("\r\n");
        sb.append("Deleted at: ").append(sdf.format(new Date())).append("\r\n");
        List<TbPackage> packages = null;
        if (user.getAccountType() == AccountType.CUSTOMER) {
            TbUserProfile userProfile = userProfileDao.get(context.getUserId());
            if (userProfile.getFirstName() != null) {
                sb.append("First name: ").append(userProfile.getFirstName()).append("\r\n");
            }
            if (userProfile.getLastName() != null) {
                sb.append("Last name: ").append(userProfile.getLastName()).append("\r\n");
            }
            packages = packageDao.getAllPackages(user.getAccountType(), context.getUserId());
        }
        if (user.getAccountType() == AccountType.PUDO) {
            Long pudoId = pudoService.getCurrentPudoId();
            TbPudo pudo = pudoDao.get(pudoId);
            sb.append("PUDO name: ").append(pudo.getBusinessName()).append("\r\n");
            if (pudo.getPublicPhoneNumber() != null) {
                sb.append("PUDO phone number: ").append(pudo.getBusinessName()).append("\r\n");
            }
            TbAddress address = addressDao.get(pudoId);
            sb.append("PUDO address: ").append(address.getLabel()).append("\r\n");
            packages = packageDao.getAllPackages(user.getAccountType(), pudoId);
        }
        if (packages != null && !packages.isEmpty()) {
            sb.append("\r\n");
            sb.append("Received packages: ").append("\r\n");
            sb.append(packages.stream()
                    .map(i -> String.format("- Package %s, received at: %s", cryptoService.hashidEncodeShort(i.getPackageId()), sdf.format(i.getCreateTms())))
                    .collect(Collectors.joining("\r\n")));
        }
        return sb.toString();
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

    private void sendOtpMessage(String phoneNumber, String otp) {
        String text = localizationService.getMessage(context.getLanguage(), "message.otp", otp);
        try {
            smsService.sendSms(phoneNumber, text);
        } catch (RuntimeException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
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
