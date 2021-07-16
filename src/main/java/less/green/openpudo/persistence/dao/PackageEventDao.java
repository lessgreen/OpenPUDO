package less.green.openpudo.persistence.dao;

import java.util.Collections;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbPackageEvent;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageEventDao extends BaseEntityDao<TbPackageEvent, Long> {

    public PackageEventDao() {
        super(TbPackageEvent.class, "packageEventId");
    }

    public List<TbPackageEvent> getPackageEventsByPackageId(Long packageId) {
        String qs = "SELECT t FROM TbPackageEvent t WHERE packageId = :packageId ORDER BY createTms";
        TypedQuery<TbPackageEvent> q = em.createQuery(qs, TbPackageEvent.class);
        q.setParameter("packageId", packageId);
        List<TbPackageEvent> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
