package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbPackage;
import less.green.openpudo.business.model.TbPackageEvent;
import less.green.openpudo.common.dto.tuple.Pair;

import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.Collections;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageDao extends BaseEntityDao<TbPackage, Long> {

    public PackageDao() {
        super(TbPackage.class, "packageId");
    }

    public long getPackageCountByUserId(Long userId) {
        String qs = "SELECT COUNT(*) FROM TbPackage t WHERE t.userId = :userId ";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        return q.getSingleResult();
    }

    public long getPackageCountByPudoId(Long pudoId) {
        String qs = "SELECT COUNT(*) FROM TbPackage t WHERE t.pudoId = :pudoId ";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("pudoId", pudoId);
        return q.getSingleResult();
    }

    public Pair<TbPackage, List<TbPackageEvent>> getPackage(Long packageId) {
        TbPackage pack = get(packageId);
        if (pack == null) {
            return null;
        }
        String qs = "SELECT t FROM TbPackageEvent t WHERE t.packageId = :packageId ORDER BY t.createTms DESC";
        TypedQuery<TbPackageEvent> q = em.createQuery(qs, TbPackageEvent.class);
        q.setParameter("packageId", packageId);
        List<TbPackageEvent> rs = q.getResultList();
        return new Pair<>(pack, rs.isEmpty() ? Collections.emptyList() : rs);
    }

}
