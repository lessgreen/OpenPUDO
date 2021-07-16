package less.green.openpudo.persistence.service;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import less.green.openpudo.cdi.service.StorageService;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.ExternalFileDao;
import less.green.openpudo.persistence.dao.NotificationDao;
import less.green.openpudo.persistence.dao.PackageDao;
import less.green.openpudo.persistence.dao.PackageEventDao;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.TbExternalFile;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.rest.dto.map.pack.PackageRequest;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class PackageService {

    @Inject
    StorageService storageService;

    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    PackageDao packageDao;
    @Inject
    PackageEventDao packageEventDao;
    @Inject
    NotificationDao notificationDao;

    public TbPackage getPackageShallowById(Long packageId) {
        return packageDao.get(packageId);
    }

    public Pair<TbPackage, List<TbPackageEvent>> getPackageById(Long packageId) {
        TbPackage pack = packageDao.get(packageId);
        if (pack == null) {
            return null;
        }
        List<TbPackageEvent> events = packageEventDao.getPackageEventsByPackageId(packageId);
        return new Pair<>(pack, events);
    }

    public Pair<TbPackage, List<TbPackageEvent>> deliveredPackage(Long pudoId, PackageRequest req) {
        Date now = new Date();
        TbPackage pack = new TbPackage();
        pack.setCreateTms(now);
        pack.setUpdateTms(now);
        pack.setPudoId(pudoId);
        pack.setUserId(req.getUserId());
        pack.setPackageStatus(PackageStatus.DELIVERED);
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

    public Pair<TbPackage, List<TbPackageEvent>> updatePackagePicture(Long packageId, String mimeType, byte[] bytes) {
        Date now = new Date();
        Pair<TbPackage, List<TbPackageEvent>> pack = getPackageById(packageId);
        UUID oldId = pack.getValue0().getPackagePicId();
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
        pack.getValue0().setUpdateTms(now);
        pack.getValue0().setPackagePicId(newId);
        packageDao.flush();
        // remove old row
        externalFileDao.delete(oldId);
        externalFileDao.flush();
        return pack;
    }

}
