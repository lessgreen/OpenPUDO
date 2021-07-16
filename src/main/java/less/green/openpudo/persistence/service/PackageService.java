package less.green.openpudo.persistence.service;

import java.util.Arrays;
import java.util.Date;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.NotificationDao;
import less.green.openpudo.persistence.dao.PackageDao;
import less.green.openpudo.persistence.dao.PackageEventDao;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.rest.dto.map.pack.PackageRequest;
import lombok.extern.log4j.Log4j2;

@RequestScoped
@Transactional
@Log4j2
public class PackageService {

    @Inject
    PackageDao packageDao;
    @Inject
    PackageEventDao packageEventDao;
    @Inject
    NotificationDao notificationDao;

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

}
