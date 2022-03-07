package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.PackageStatus;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.CalendarUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.common.dto.tuple.Septet;
import less.green.openpudo.common.dto.tuple.Sextet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.notification.NotificationPackageOptData;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.*;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.*;
import java.util.stream.Collectors;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class PackageService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    CryptoService cryptoService;
    @Inject
    StorageService storageService;

    @Inject
    NotificationService notificationService;
    @Inject
    PudoService pudoService;

    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    NotificationDao notificationDao;
    @Inject
    PackageDao packageDao;
    @Inject
    PackageEventDao packageEventDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPudoRelationDao userPudoRelationDao;
    @Inject
    PudoDao pudoDao;

    @Inject
    DtoMapper dtoMapper;

    public Package getPackage(Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            return null;
        }
        // operation is allowed if the current user is the package pudo owner or the package recipient
        TbUser caller = userDao.get(context.getUserId());
        if (caller.getAccountType() == AccountType.CUSTOMER) {
            if (!rs.getValue0().getUserId().equals(context.getUserId())) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
        } else if (caller.getAccountType() == AccountType.PUDO) {
            Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
            if (!rs.getValue0().getPudoId().equals(pudoId)) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
        } else {
            throw new AssertionError("Unsupported AccountType: " + caller.getAccountType());
        }
        List<PackageEvent> events = rs.getValue1().stream().map(i -> dtoMapper.mapPackageEventEntityToDto(new Pair<>(i, getPackageStatusMessage(i.getPackageStatus())))).collect(Collectors.toList());
        return dtoMapper.mapPackageEntityToDto(new Quartet<>(rs.getValue0(), events, cryptoService.hashidEncodeShort(packageId), cryptoService.hashidEncodeLong(packageId)));
    }

    public Package getPackageByShareLink(String shareLink) {
        Long packageId = cryptoService.hashidDecodeLong(shareLink);
        if (packageId == null) {
            return null;
        }
        return getPackage(packageId);
    }

    protected List<PackageSummary> getPackages(AccountType accountType, Long referenceId, boolean history, int limit, int offset) {
        List<PackageStatus> packageStatuses;
        if (accountType == AccountType.CUSTOMER) {
            packageStatuses = history ? null : Arrays.asList(PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED, PackageStatus.COLLECTED);
        } else if (accountType == AccountType.PUDO) {
            packageStatuses = history ? null : Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED);
        } else {
            throw new AssertionError("Unsupported AccountType: " + accountType);
        }
        List<Sextet<TbPackage, TbPackageEvent, TbPudo, TbAddress, TbUserProfile, TbUserPudoRelation>> rs = packageDao.getPackages(accountType, referenceId, packageStatuses, history, limit, offset);
        List<PackageSummary> ret = new ArrayList<>(rs.size());
        for (var row : rs) {
            ret.add(dtoMapper.mapProjectionToPackageSummary(new Septet<>(row.getValue0(), row.getValue1(), row.getValue2(), row.getValue3(), row.getValue4(), row.getValue5(), cryptoService.hashidEncodeShort(row.getValue0().getPackageId()))));
        }
        return ret;
    }

    protected String getPackageStatusMessage(PackageStatus packageStatus) {
        return getPackageStatusMessage(packageStatus, null);
    }

    protected String getPackageStatusMessage(PackageStatus packageStatus, String forcedLanguage) {
        switch (packageStatus) {
            case DELIVERED:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.delivered");
            case NOTIFY_SENT:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.notify_sent");
            case NOTIFIED:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.notified");
            case COLLECTED:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.collected");
            case ACCEPTED:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.accepted");
            case EXPIRED:
                return localizationService.getMessage(forcedLanguage == null ? context.getLanguage() : forcedLanguage, "label.package.expired");
            default:
                throw new AssertionError("Unsupported mapping for PackageStatus: " + packageStatus);
        }
    }

    public Package deliveredPackage(DeliveredPackageRequest req) {
        // operation is allowed if the current user is a pudo owner
        Long pudoId = pudoService.getCurrentPudoId();
        // and if there is a customer relationship with user
        TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudoId, req.getUserId());
        if (userPudoRelation == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        Date now = new Date();
        TbPackage pack = new TbPackage();
        pack.setCreateTms(now);
        pack.setUpdateTms(now);
        pack.setPudoId(pudoId);
        pack.setUserId(req.getUserId());
        pack.setPackagePicId(null);
        packageDao.persist(pack);
        packageDao.flush();
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(pack.getPackageId());
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.DELIVERED);
        packageEvent.setAutoFlag(false);
        packageEvent.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        log.info("[{}] Package {}: {}", context.getExecutionId(), pack.getPackageId(), packageEvent.getPackageStatus());
        return getPackage(pack.getPackageId());
    }

    public UUID updatePackagePicture(Long packageId, String mimeType, byte[] bytes) {
        TbPackage pack = packageDao.get(packageId);
        if (pack == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        // operation is allowed if the current user is the package pudo owner
        Long pudoId = pudoService.getCurrentPudoId();
        if (!pack.getPudoId().equals(pudoId)) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        Date now = new Date();
        UUID oldId = pack.getPackagePicId();
        UUID newId = UUID.randomUUID();
        // save new file first
        storageService.saveFileBinary(newId, bytes);
        // delete old file if any
        if (oldId != null) {
            storageService.deleteFile(oldId);
        }
        // if everything is ok, we can update database
        // save new row
        TbExternalFile ent = new TbExternalFile();
        ent.setExternalFileId(newId);
        ent.setCreateTms(now);
        ent.setMimeType(mimeType);
        externalFileDao.persist(ent);
        externalFileDao.flush();
        // switch foreign key
        pack.setUpdateTms(now);
        pack.setPackagePicId(newId);
        packageDao.flush();
        // remove old row
        externalFileDao.delete(oldId);
        externalFileDao.flush();
        log.info("[{}] Updated picture for package: {}", context.getExecutionId(), pack.getPackageId());
        return newId;
    }

    public Package notifiedPackage(Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        // operation is allowed if the current user is the package recipient
        if (!rs.getValue0().getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        // since the user can react to push notification even much after
        // if package is in expected states we make the transition, otherwise we silently skip it and return the current state
        if (rs.getValue1().get(0).getPackageStatus() == PackageStatus.DELIVERED
            || rs.getValue1().get(0).getPackageStatus() == PackageStatus.NOTIFY_SENT) {
            Date now = new Date();
            rs.getValue0().setUpdateTms(now);
            TbPackageEvent packageEvent = new TbPackageEvent();
            packageEvent.setPackageId(packageId);
            packageEvent.setCreateTms(now);
            packageEvent.setPackageStatus(PackageStatus.NOTIFIED);
            packageEvent.setAutoFlag(false);
            packageEvent.setNotes(null);
            packageEventDao.persist(packageEvent);
            packageEventDao.flush();
            log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
        }

        return getPackage(packageId);
    }

    public Package collectedPackage(Long packageId, ChangePackageStatusRequest req) {
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        // operation is allowed if the current user is the package pudo owner
        Long pudoId = pudoService.getCurrentPudoId();
        if (!rs.getValue0().getPudoId().equals(pudoId)) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        // operation is allowed if the package is in those states
        if (rs.getValue1().get(0).getPackageStatus() != PackageStatus.DELIVERED
            && rs.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFY_SENT
            && rs.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFIED) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.package.illegal_state"));
        }

        Date now = new Date();
        rs.getValue0().setUpdateTms(now);
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(packageId);
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.COLLECTED);
        packageEvent.setAutoFlag(false);
        packageEvent.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        // save notification for user
        TbPudo pudo = pudoDao.get(rs.getValue0().getPudoId());
        String titleTemplate = "notification.package.collected.title";
        String messageTemplate = "notification.package.collected.message";
        String[] messageParams = {pudo.getBusinessName(), cryptoService.hashidEncodeShort(packageId)};
        TbNotificationPackage notification = new TbNotificationPackage();
        notification.setUserId(rs.getValue0().getUserId());
        notification.setCreateTms(now);
        notification.setQueuedFlag(false);
        notification.setDueTms(now);
        notification.setReadTms(null);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(messageParams);
        notification.setPackageId(packageId);
        notificationDao.persist(notification);
        notificationDao.flush();
        // send push
        NotificationPackageOptData optData = new NotificationPackageOptData(notification.getNotificationId().toString(), packageId.toString());
        notificationService.sendPushNotifications(rs.getValue0().getUserId(), titleTemplate, null, messageTemplate, messageParams, optData.toMap());

        log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
        return getPackage(packageId);
    }

    public Package acceptedPackage(Long packageId, ChangePackageStatusRequest req) {
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.resource_not_exists"));
        }
        // operation is allowed if the current user is the package recipient
        if (!rs.getValue0().getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        // operation is allowed if the package is in those states
        if (rs.getValue1().get(0).getPackageStatus() != PackageStatus.DELIVERED
            && rs.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFY_SENT
            && rs.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFIED
            && rs.getValue1().get(0).getPackageStatus() != PackageStatus.COLLECTED) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.package.illegal_state"));
        }

        Date now = new Date();
        rs.getValue0().setUpdateTms(now);
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(packageId);
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.ACCEPTED);
        packageEvent.setAutoFlag(false);
        packageEvent.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        // save notification for pudo owner
        Long ownerUserId = userPudoRelationDao.getOwnerUserIdByPudoId(rs.getValue0().getPudoId());
        String titleTemplate = "notification.package.accepted.title";
        String messageTemplate = "notification.package.accepted.message";
        String[] messageParams = {cryptoService.hashidEncodeShort(packageId)};
        TbNotificationPackage notification = new TbNotificationPackage();
        notification.setUserId(ownerUserId);
        notification.setCreateTms(now);
        notification.setQueuedFlag(false);
        notification.setDueTms(now);
        notification.setReadTms(null);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(messageParams);
        notification.setPackageId(packageId);
        notificationDao.persist(notification);
        notificationDao.flush();
        // send push
        NotificationPackageOptData optData = new NotificationPackageOptData(notification.getNotificationId().toString(), packageId.toString());
        notificationService.sendPushNotifications(ownerUserId, titleTemplate, null, messageTemplate, messageParams, optData.toMap());

        log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
        return getPackage(packageId);
    }

    public List<Long> getPackageIdsToNotifySent() {
        // get packages in delivered status for more than 30 seconds
        Date timeThreshold = CalendarUtils.getDateWithOffset(new Date(), Calendar.SECOND, -30);
        return packageDao.getPackageIdsToNotifySent(timeThreshold);
    }

    public void notifySentPackage(Long packageId) {
        // we are coming from a cron job, so no need to check the existence of the package nor the grants to access it
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        rs.getValue0().setUpdateTms(now);
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(packageId);
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.NOTIFY_SENT);
        packageEvent.setAutoFlag(true);
        packageEvent.setNotes(null);
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        // save notification for user
        TbPudo pudo = pudoDao.get(rs.getValue0().getPudoId());
        String titleTemplate = "notification.package.delivered.title";
        String messageTemplate = "notification.package.delivered.message";
        String[] messageParams = {cryptoService.hashidEncodeShort(packageId), pudo.getBusinessName()};
        TbNotificationPackage notification = new TbNotificationPackage();
        notification.setUserId(rs.getValue0().getUserId());
        notification.setCreateTms(now);
        notification.setQueuedFlag(false);
        notification.setDueTms(now);
        notification.setReadTms(null);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(messageParams);
        notification.setPackageId(packageId);
        notificationDao.persist(notification);
        notificationDao.flush();
        // send push
        NotificationPackageOptData optData = new NotificationPackageOptData(notification.getNotificationId().toString(), packageId.toString());
        notificationService.sendPushNotifications(rs.getValue0().getUserId(), titleTemplate, null, messageTemplate, messageParams, optData.toMap());

        log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
    }

    public List<Long> getPackageIdsToExpired() {
        // get packages in notified or notify_sent status for more than 30 days
        Date timeThreshold = CalendarUtils.getDateWithOffset(new Date(), Calendar.DAY_OF_MONTH, -30);
        return packageDao.getPackageIdsToExpired(timeThreshold);
    }

    public void expiredPackage(Long packageId) {
        // we are coming from a cron job, so no need to check the existence of the package nor the grants to access it
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        rs.getValue0().setUpdateTms(now);
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(packageId);
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.EXPIRED);
        packageEvent.setAutoFlag(true);
        packageEvent.setNotes(null);
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
    }

    public List<Long> getPackageIdsToAccepted() {
        // get packages in collected status for more than 7 days
        Date timeThreshold = CalendarUtils.getDateWithOffset(new Date(), Calendar.DAY_OF_MONTH, -7);
        return packageDao.getPackageIdsToAccepted(timeThreshold);
    }

    public void autoAcceptedPackage(Long packageId) {
        // we are coming from a cron job, so no need to check the existence of the package nor the grants to access it
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        rs.getValue0().setUpdateTms(now);
        TbPackageEvent packageEvent = new TbPackageEvent();
        packageEvent.setPackageId(packageId);
        packageEvent.setCreateTms(now);
        packageEvent.setPackageStatus(PackageStatus.ACCEPTED);
        packageEvent.setAutoFlag(true);
        packageEvent.setNotes(null);
        packageEventDao.persist(packageEvent);
        packageEventDao.flush();

        log.info("[{}] Package {}: {} -> {}", context.getExecutionId(), packageId, rs.getValue1().get(0).getPackageStatus(), packageEvent.getPackageStatus());
    }

}
