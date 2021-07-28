package less.green.openpudo.persistence.service;

import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.SendResponse;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.FirebaseMessagingService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.DeviceTokenDao;
import less.green.openpudo.persistence.dao.ExternalFileDao;
import less.green.openpudo.persistence.dao.NotificationDao;
import less.green.openpudo.persistence.dao.PackageDao;
import less.green.openpudo.persistence.dao.PackageEventDao;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbDeviceToken;
import less.green.openpudo.persistence.model.TbExternalFile;
import less.green.openpudo.persistence.model.TbNotification;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.rest.dto.pack.CollectedPackageRequest;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import lombok.extern.log4j.Log4j2;

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
        pack.setPackagePicId(req.getPackage_pic_id());
        packageDao.persist(pack);
        packageDao.flush();
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(pack.getPackageId());
        event.setPackageStatus(PackageStatus.DELIVERED);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();

        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pudoId);
        String notificationTitle = localizationService.getMessage("notification.package.delivered.title");
        String notificationMessage = localizationService.getMessage("notification.package.delivered.message", pudo.getValue0().getBusinessName());

        TbNotification notif = new TbNotification();
        notif.setUserId(req.getUserId());
        notif.setCreateTms(now);
        notif.setTitle(notificationTitle);
        notif.setMessage(notificationMessage);
        notificationDao.persist(notif);
        notificationDao.flush();

        sendNotifications(req.getUserId(), notificationTitle, notificationMessage);
        return new Pair<>(pack, Arrays.asList(event));
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

    public Pair<TbPackage, List<TbPackageEvent>> collectedPackage(Long packageId, CollectedPackageRequest req) {
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> pack = getPackageById(packageId);
        TbPackageEvent event = new TbPackageEvent();
        event.setCreateTms(now);
        event.setPackageId(packageId);
        event.setPackageStatus(PackageStatus.COLLECTED);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();

        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pack.getValue0().getPudoId());
        String notificationTitle = localizationService.getMessage("notification.package.collected.title");
        String notificationMessage = localizationService.getMessage("notification.package.collected.message", pudo.getValue0().getBusinessName());

        TbNotification notif = new TbNotification();
        notif.setUserId(pack.getValue0().getUserId());
        notif.setCreateTms(now);
        notif.setTitle(notificationTitle);
        notif.setMessage(notificationMessage);
        notificationDao.persist(notif);
        notificationDao.flush();

        sendNotifications(pack.getValue0().getUserId(), notificationTitle, notificationMessage);
        return getPackageById(packageId);
    }

    private void sendNotifications(Long userId, String notificationTitle, String notificationMessage) {
        Date now = new Date();
        List<TbDeviceToken> deviceTokens = deviceTokenDao.getDeviceTokensByUserId(userId);
        if (!deviceTokens.isEmpty()) {
            BatchResponse responses = firebaseMessagingService.sendNotification(deviceTokens.stream().map(i -> i.getDeviceToken()).collect(Collectors.toList()), notificationTitle, notificationMessage, null);
            if (responses != null) {
                for (int i = 0; i < responses.getResponses().size(); i++) {
                    TbDeviceToken curRow = deviceTokens.get(i);
                    SendResponse resp = responses.getResponses().get(i);
                    if (resp.isSuccessful()) {
                        curRow.setLastSuccessTms(now);
                        curRow.setLastSuccessMessageId(resp.getMessageId());
                    } else {
                        curRow.setLastFailureTms(now);
                        curRow.setFailureCount(curRow.getFailureCount() == null ? 1 : curRow.getFailureCount() + 1);
                    }
                }
                deviceTokenDao.flush();
            }
        }
    }

}
