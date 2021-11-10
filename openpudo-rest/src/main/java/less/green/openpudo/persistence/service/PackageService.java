package less.green.openpudo.persistence.service;

import less.green.openpudo.cdi.service.FirebaseMessagingService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.Encoders;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.*;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.*;
import less.green.openpudo.rest.dto.notification.PackageNotificationOptData;
import less.green.openpudo.rest.dto.pack.ChangePackageStatusRequest;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.*;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional
@Log4j2
public class PackageService {

    @Inject
    FirebaseMessagingService firebaseMessagingService;
    @Inject
    LocalizationService localizationService;
    @Inject
    StorageService storageService;

    @Inject
    PudoService pudoService;

    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    PackageDao packageDao;
    @Inject
    PackageEventDao packageEventDao;
    @Inject
    NotificationDao notificationDao;

    public Pair<TbPackage, List<TbPackageEvent>> getPackageById(Long packageId) {
        return packageDao.getPackageById(packageId);
    }

    public long getActivePackageCount(Long pudoId, Long userId) {
        return packageDao.getActivePackageCount(pudoId, userId);
    }

    public void uploadPackagePicture(UUID externalFileId, String mimeType, byte[] bytes) {
        Date now = new Date();
        storageService.saveFileBinary(externalFileId, bytes);
        TbExternalFile ent = new TbExternalFile();
        ent.setExternalFileId(externalFileId);
        ent.setCreateTms(now);
        ent.setMimeType(mimeType);
        externalFileDao.persist(ent);
        externalFileDao.flush();
    }

    public Pair<TbPackage, List<TbPackageEvent>> deliveredPackage(Long pudoId, DeliveredPackageRequest req) {
        Date now = new Date();
        TbPackage pack = new TbPackage();
        pack.setCreateTms(now);
        pack.setUpdateTms(now);
        pack.setPudoId(pudoId);
        pack.setUserId(req.getUserId());
        pack.setPackagePicId(req.getPackagePicId());
        packageDao.persist(pack);
        packageDao.flush();
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(pack.getPackageId());
        event.setPackageStatus(PackageStatus.DELIVERED);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();
        return new Pair<>(pack, Arrays.asList(event));
    }

    public List<Pair<TbPackage, List<TbPackageEvent>>> getDeliveredPackageShallowList() {
        // get packages in delivered status for more than 2 minutes
        Calendar cal = GregorianCalendar.getInstance();
        cal.setLenient(false);
        cal.add(Calendar.MINUTE, -2);
        return packageDao.getDeliveredPackageShallowList(cal.getTime());
    }

    public Pair<TbPackage, List<TbPackageEvent>> notifySentPackage(Long packageId) {
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> pack = packageDao.getPackageShallowById(packageId);
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pack.getValue0().getPudoId());
        String titleTemplate = "notification.package.delivered.title";
        String messageTemplate = "notification.package.delivered.message";
        String[] messageParams = {pudo.getValue0().getBusinessName()};

        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(pack.getValue0().getPackageId());
        event.setPackageStatus(PackageStatus.NOTIFY_SENT);
        packageEventDao.persist(event);
        packageEventDao.flush();

        TbNotification notification = new TbNotification();
        notification.setUserId(pack.getValue0().getUserId());
        notification.setCreateTms(now);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(messageParams);
        notificationDao.persist(notification);
        notificationDao.flush();
        PackageNotificationOptData optData = new PackageNotificationOptData(notification.getNotificationId(), pack.getValue0().getPackageId(), PackageStatus.NOTIFY_SENT);
        notification.setOptData(Encoders.writeValueAsStringSafe(optData.toMap()));
        notificationDao.flush();

        sendPushNotifications(pack.getValue0().getUserId(), titleTemplate, null, messageTemplate, messageParams, optData.toMap());
        return getPackageById(packageId);
    }

    public Pair<TbPackage, List<TbPackageEvent>> notifiedPackage(Long packageId) {
        Date now = new Date();
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(packageId);
        event.setPackageStatus(PackageStatus.NOTIFIED);
        packageEventDao.persist(event);
        packageEventDao.flush();
        return getPackageById(packageId);
    }

    public Pair<TbPackage, List<TbPackageEvent>> collectedPackage(Long packageId, ChangePackageStatusRequest req) {
        Date now = new Date();
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(packageId);
        event.setPackageStatus(PackageStatus.COLLECTED);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();

        Pair<TbPackage, List<TbPackageEvent>> pack = getPackageById(packageId);
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pack.getValue0().getPudoId());
        String titleTemplate = "notification.package.collected.title";
        String messageTemplate = "notification.package.collected.message";
        String[] messageParams = {pudo.getValue0().getBusinessName()};

        TbNotification notification = new TbNotification();
        notification.setUserId(pack.getValue0().getUserId());
        notification.setCreateTms(now);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(messageParams);
        notificationDao.persist(notification);
        notificationDao.flush();
        PackageNotificationOptData optData = new PackageNotificationOptData(notification.getNotificationId(), packageId, PackageStatus.COLLECTED);
        notification.setOptData(Encoders.writeValueAsStringSafe(optData.toMap()));
        notificationDao.flush();

        sendPushNotifications(pack.getValue0().getUserId(), titleTemplate, null, messageTemplate, messageParams, optData.toMap());
        return getPackageById(packageId);
    }

    public Pair<TbPackage, List<TbPackageEvent>> acceptedPackage(Long packageId, ChangePackageStatusRequest req) {
        Date now = new Date();
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(packageId);
        event.setPackageStatus(PackageStatus.ACCEPTED);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();

        Pair<TbPackage, List<TbPackageEvent>> pack = getPackageById(packageId);
        String titleTemplate = "notification.package.accepted.title";
        String messageTemplate = "notification.package.accepted.message";

        TbNotification notification = new TbNotification();
        notification.setUserId(pack.getValue0().getUserId());
        notification.setCreateTms(now);
        notification.setTitle(titleTemplate);
        notification.setTitleParams(null);
        notification.setMessage(messageTemplate);
        notification.setMessageParams(null);
        notificationDao.persist(notification);
        notificationDao.flush();
        PackageNotificationOptData optData = new PackageNotificationOptData(notification.getNotificationId(), packageId, PackageStatus.ACCEPTED);
        notification.setOptData(Encoders.writeValueAsStringSafe(optData.toMap()));
        notificationDao.flush();

        return getPackageById(packageId);
    }

    public List<Pair<TbPackage, List<TbPackageEvent>>> getPackageList(Long userId, boolean history, int limit, int offset) {
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoByOwner(userId);
        if (pudo != null) {
            return packageDao.getPackageShallowList(PackageDao.Pov.PUDO, pudo.getValue0().getPudoId(), history, limit, offset);
        } else {
            return packageDao.getPackageShallowList(PackageDao.Pov.USER, userId, history, limit, offset);
        }
    }

    private void sendPushNotifications(Long userId, String titleTemplate, String[] titleParams, String messageTemplate, String[] messageParams, Map<String, String> data) {
        List<TbDeviceToken> deviceTokens = deviceTokenDao.getDeviceTokensByUserId(userId);
        if (deviceTokens != null && !deviceTokens.isEmpty()) {
            Date now = new Date();
            for (TbDeviceToken curRow : deviceTokens) {
                String title;
                if (titleParams == null || titleParams.length == 0) {
                    title = localizationService.getMessage(curRow.getApplicationLanguage(), titleTemplate);
                } else {
                    title = localizationService.getMessage(curRow.getApplicationLanguage(), titleTemplate, (Object[]) titleParams);
                }
                String message;
                if (messageParams == null || messageParams.length == 0) {
                    message = localizationService.getMessage(curRow.getApplicationLanguage(), messageTemplate);
                } else {
                    message = localizationService.getMessage(curRow.getApplicationLanguage(), messageTemplate, (Object[]) messageParams);
                }
                String messageId = firebaseMessagingService.sendNotification(curRow.getDeviceToken(), title, message, data);

                curRow.setUpdateTms(now);
                if (messageId != null) {
                    curRow.setLastSuccessTms(now);
                    curRow.setLastSuccessMessageId(messageId);
                    curRow.setLastFailureTms(null);
                    curRow.setFailureCount(0);
                } else {
                    curRow.setLastFailureTms(now);
                    curRow.setFailureCount(curRow.getFailureCount() + 1);
                }
            }
            deviceTokenDao.flush();
        }
    }

}