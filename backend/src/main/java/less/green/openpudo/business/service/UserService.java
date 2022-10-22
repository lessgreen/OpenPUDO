package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.FormatUtils;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pack.PackageSummary;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import less.green.openpudo.rest.dto.user.DeviceToken;
import less.green.openpudo.rest.dto.user.User;
import less.green.openpudo.rest.dto.user.UserPreferences;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

import static less.green.openpudo.common.StringUtils.isEmpty;
import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class UserService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    ExternalFileService externalFileService;
    @Inject
    PackageService packageService;
    @Inject
    PudoService pudoService;

    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    NotificationDao notificationDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    PackageDao packageDao;
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

    public User getUserProfile(Long userId) {
        TbUser caller = userDao.get(context.getUserId());
        if (caller.getAccountType() == AccountType.CUSTOMER) {
            if (context.getUserId().equals(userId)) {
                return getCurrentUserProfile();
            } else {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
        } else if (caller.getAccountType() == AccountType.PUDO) {
            Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
            // check if pudo is granted to see user's profile
            TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudoId, userId);
            if (userPudoRelation == null) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
            TbUserProfile userProfile = userProfileDao.get(userId);
            // check if pudo is granted to see user's phone number
            TbUserPreferences userPreferences = userPreferencesDao.get(userId);
            String phoneNumber = userPreferences.getShowPhoneNumber() ? userDao.get(userId).getPhoneNumber() : null;
            long packageCount = packageDao.getPackageCountByUserId(context.getUserId());
            return dtoMapper.mapUserDto(userProfile, phoneNumber, packageCount, FormatUtils.calcSavedCO2(packageCount), userPudoRelation.getCustomerSuffix());
        } else {
            throw new AssertionError("Unsupported AccountType: " + caller.getAccountType());
        }
    }

    public User getCurrentUserProfile() {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());
        long packageCount = packageDao.getPackageCountByUserId(context.getUserId());
        return dtoMapper.mapUserDto(userProfile, user.getPhoneNumber(), packageCount, FormatUtils.calcSavedCO2(packageCount), null);
    }

    public User updateCurrentUserProfile(User req) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());
        userProfile.setUpdateTms(Instant.now());
        userProfile.setFirstName(sanitizeString(req.getFirstName()));
        userProfile.setLastName(sanitizeString(req.getLastName()));
        userProfileDao.flush();
        log.info("[{}] Updated profile for user: {}", context.getExecutionId(), context.getUserId());
        return getCurrentUserProfile();
    }

    public UUID updateCurrentUserProfilePicture(byte[] bytes) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());

        TbExternalFile externalFile = externalFileService.saveExternalImage(bytes);
        UUID oldId = userProfile.getProfilePicId();
        UUID newId = externalFile.getExternalFileId();
        // switch foreign key
        userProfile.setUpdateTms(externalFile.getCreateTms());
        userProfile.setProfilePicId(externalFile.getExternalFileId());
        if (oldId != null) {
            externalFileService.deleteExternalFile(oldId);
        }
        log.info("[{}] Updated profile picture for user: {}", context.getExecutionId(), context.getUserId());
        return newId;
    }

    public UserPreferences getCurrentUserPreferences() {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserPreferences userPreferences = userPreferencesDao.get(context.getUserId());
        return dtoMapper.mapUserPreferencesDto(userPreferences);
    }

    public UserPreferences updateCurrentUserPreferences(UserPreferences req) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserPreferences userPreferences = userPreferencesDao.get(context.getUserId());
        userPreferences.setUpdateTms(Instant.now());
        userPreferences.setShowPhoneNumber(req.getShowPhoneNumber());
        userPreferencesDao.flush();
        log.info("[{}] Updated preferences for user: {}", context.getExecutionId(), context.getUserId());
        return dtoMapper.mapUserPreferencesDto(userPreferences);
    }

    public void upsertDeviceToken(DeviceToken req) {
        Instant now = Instant.now();
        TbDeviceToken token = deviceTokenDao.get(req.getDeviceToken().trim());
        if (token == null) {
            // if not found, associate it with current user
            token = new TbDeviceToken();
            token.setDeviceToken(sanitizeString(req.getDeviceToken()));
            token.setUserId(context.getUserId());
            token.setCreateTms(now);
            token.setUpdateTms(now);
            token.setDeviceType(sanitizeString(req.getDeviceType()));
            token.setSystemName(sanitizeString(req.getSystemName()));
            token.setSystemVersion(sanitizeString(req.getSystemVersion()));
            token.setModel(sanitizeString(req.getModel()));
            token.setResolution(sanitizeString(req.getResolution()));
            token.setApplicationLanguage(context.getLanguage());
            token.setFailureCount(0);
            deviceTokenDao.persist(token);
        } else {
            if (!context.getUserId().equals(token.getUserId())) {
                // if associated with another user, recreate association
                token.setUserId(context.getUserId());
                token.setCreateTms(now);
                token.setLastSuccessTms(null);
                token.setLastSuccessMessageId(null);
                token.setLastFailureTms(null);
                token.setFailureCount(0);
            }
            token.setUpdateTms(now);
            token.setDeviceType(sanitizeString(req.getDeviceType()));
            token.setSystemName(sanitizeString(req.getSystemName()));
            token.setSystemVersion(sanitizeString(req.getSystemVersion()));
            token.setModel(sanitizeString(req.getModel()));
            token.setResolution(sanitizeString(req.getResolution()));
            token.setApplicationLanguage(context.getLanguage());
        }
        deviceTokenDao.flush();
    }

    public List<PudoSummary> getCurrentUserPudos() {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        List<Quartet<TbPudo, TbAddress, TbUserPudoRelation, TbRating>> rs = pudoDao.getUserPudos(context.getUserId());
        return rs.stream().map(i -> dtoMapper.mapPudoSummaryDto(i.getValue0().getPudoId(), i.getValue0().getBusinessName(), i.getValue0().getPudoPicId(), i.getValue1().getLabel(), i.getValue3(),
                pudoService.createCustomizedAddress(i.getValue0(), i.getValue1(), i.getValue2().getCustomerSuffix()))).collect(Collectors.toList());
    }

    public List<PudoSummary> addPudoToFavourites(Long pudoId) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbUserProfile userProfile = userProfileDao.get(context.getUserId());
        if (!isUserProfileComplete(userProfile)) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.user_profile_incomplete"));
        }
        TbPudo pudo = pudoDao.get(pudoId);
        if (pudo == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        // check if there is a relation already
        TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudo.getPudoId(), context.getUserId());
        if (userPudoRelation != null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.forbidden.pudo_already_favourite"));
        }
        // if not, check if there was in the past
        String customerSuffix = userPudoRelationDao.getPastCustomerSuffix(pudoId, context.getUserId());
        // if is the first relation between pudo and customer, generate a random unique suffix
        if (customerSuffix == null) {
            Set<String> suffixes = userPudoRelationDao.getCustomerSuffixesByPudoId(pudoId);
            // we keep randomizing until we get a suffix never used before for that specific pudo
            do {
                customerSuffix = generateCustomerSuffix(userProfile.getFirstName(), userProfile.getLastName());
            } while (suffixes.contains(customerSuffix));
        }
        Instant now = Instant.now();
        userPudoRelation = new TbUserPudoRelation();
        userPudoRelation.setUserId(context.getUserId());
        userPudoRelation.setPudoId(pudoId);
        userPudoRelation.setCreateTms(now);
        userPudoRelation.setDeleteTms(null);
        userPudoRelation.setRelationType(RelationType.CUSTOMER);
        userPudoRelation.setCustomerSuffix(customerSuffix);
        userPudoRelationDao.persist(userPudoRelation);
        userPudoRelationDao.flush();

        // queue notification to pudo owner
        Long ownerUserId = userPudoRelationDao.getOwnerUserIdByPudoId(pudoId);
        TbNotificationFavourite notification = new TbNotificationFavourite();
        notification.setUserId(ownerUserId);
        notification.setCreateTms(now);
        notification.setQueuedFlag(true);
        notification.setDueTms(now.plus(10, ChronoUnit.MINUTES));
        notification.setReadTms(null);
        notification.setTitle("notification.relation.favourite.title");
        notification.setTitleParams(null);
        notification.setMessage("notification.relation.favourite.message");
        notification.setMessageParams(new String[]{customerSuffix});
        notification.setCustomerUserId(context.getUserId());
        notification.setPudoId(pudoId);
        notificationDao.persist(notification);
        notificationDao.flush();

        log.info("[{}] Added PUDO: {} to favourites of user: {}", context.getExecutionId(), pudoId, context.getUserId());
        return getCurrentUserPudos();
    }

    public List<PudoSummary> removePudoFromFavourites(Long pudoId) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        TbPudo pudo = pudoDao.get(pudoId);
        if (pudo == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudo.getPudoId(), context.getUserId());
        if (userPudoRelation == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.forbidden.pudo_not_favourite"));
        }
        // prevent removal if there are packages in transit
        if (packageDao.getActivePackageCount(pudoId, context.getUserId()) > 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.forbidden.package_in_transit"));
        }

        userPudoRelation.setDeleteTms(Instant.now());
        userPudoRelationDao.flush();
        notificationDao.removeQueuedNotificationFavourite(context.getUserId(), pudo.getPudoId());
        log.info("[{}] Removed PUDO: {} from favourites of user: {}", context.getExecutionId(), pudoId, context.getUserId());
        return getCurrentUserPudos();
    }

    public List<PackageSummary> getCurrentUserPackages(boolean history, int limit, int offset) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.CUSTOMER) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        return packageService.getPackages(AccountType.CUSTOMER, context.getUserId(), history, limit, offset);
    }

    private boolean isUserProfileComplete(TbUserProfile userProfile) {
        return (!isEmpty(userProfile.getFirstName()) && !isEmpty(userProfile.getLastName()) || userProfile.getProfilePicId() != null);
    }

    private String generateCustomerSuffix(String firstName, String lastName) {
        // we remove B/I/O and 0/1/8 which can confuse future OCR implementation
        final String alphabet = "ACDEFGHJKLMNPQRSTUVWXYZ";
        final String numbers = "2345679";
        // we don't need cryptographically secure RNG
        ThreadLocalRandom rand = ThreadLocalRandom.current();
        StringBuilder sb = new StringBuilder(5);
        // customer suffix if a 5 letter string: 2 letters (with customer initials if available) and 3 numbers
        if (!isEmpty(firstName) && !isEmpty(lastName)) {
            sb.append(firstName.substring(0, 1).toUpperCase());
            sb.append(lastName.substring(0, 1).toUpperCase());
        } else {
            sb.append(alphabet.charAt(rand.nextInt(alphabet.length())));
            sb.append(alphabet.charAt(rand.nextInt(alphabet.length())));
        }
        sb.append(numbers.charAt(rand.nextInt(numbers.length())));
        sb.append(numbers.charAt(rand.nextInt(numbers.length())));
        sb.append(numbers.charAt(rand.nextInt(numbers.length())));
        return sb.toString();
    }

}
