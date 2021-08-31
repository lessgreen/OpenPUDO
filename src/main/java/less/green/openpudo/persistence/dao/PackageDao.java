package less.green.openpudo.persistence.dao;

import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageDao extends BaseEntityDao<TbPackage, Long> {

    public PackageDao() {
        super(TbPackage.class, "packageId");
    }

    public enum Pov {
        PUDO,
        USER
    }

    public Pair<TbPackage, List<TbPackageEvent>> getPackageShallowById(Long packageId) {
        String qs = "SELECT t1, t2 "
                + "FROM TbPackage t1, TbPackageEvent t2 "
                + "WHERE t1.packageId = t2.packageId "
                + "AND t1.packageId = :packageId "
                + "AND t2.createTms = (SELECT MAX(t3.createTms) FROM TbPackageEvent t3 WHERE t3.packageId = t2.packageId)";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("packageId", packageId);
        Object[] rs = q.getSingleResult();
        return rs == null ? null : new Pair<>((TbPackage) rs[0], Arrays.asList((TbPackageEvent) rs[1]));
    }

    public Pair<TbPackage, List<TbPackageEvent>> getPackageById(Long packageId) {
        TbPackage pack = get(packageId);
        if (pack == null) {
            return null;
        }
        String qs = "SELECT t FROM TbPackageEvent t WHERE t.packageId = :packageId ORDER BY t.createTms DESC";
        TypedQuery<TbPackageEvent> q = em.createQuery(qs, TbPackageEvent.class);
        q.setParameter("packageId", packageId);
        List<TbPackageEvent> rs = q.getResultList();
        return new Pair<>(pack, rs);
    }

    public List<Pair<TbPackage, List<TbPackageEvent>>> getPackageShallowList(Pov pov, Long referenceId, boolean history, int limit, int offset) {
        String qs = "SELECT t1, t2 "
                + "FROM TbPackage t1, TbPackageEvent t2 "
                + "WHERE t1.packageId = t2.packageId "
                + "AND t2.createTms = (SELECT MAX(t3.createTms) FROM TbPackageEvent t3 WHERE t3.packageId = t2.packageId)";
        if (pov == Pov.PUDO) {
            qs += " AND t1.pudoId = :referenceId";
        } else {
            qs += " AND t1.userId = :referenceId";
        }
        if (!history) {
            qs += " AND t2.packageStatus IN :packageStatusList";
        }
        qs += " ORDER BY t1.createTms DESC";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("referenceId", referenceId);
        if (!history) {
            if (pov == Pov.PUDO) {
                q.setParameter("packageStatusList", Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED));
            } else {
                q.setParameter("packageStatusList", Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED, PackageStatus.COLLECTED));
            }
        } else {
            q.setMaxResults(limit);
            q.setFirstResult(offset);
        }
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Pair<>((TbPackage) row[0], Arrays.asList((TbPackageEvent) row[1]))).collect(Collectors.toList());
    }

    public List<Pair<TbPackage, List<TbPackageEvent>>> getDeliveredPackageShallowList(Date timeThreshold) {
        String qs = "SELECT t1, t2 "
                + "FROM TbPackage t1, TbPackageEvent t2 "
                + "WHERE t1.packageId = t2.packageId "
                + "AND t2.createTms = (SELECT MAX(t3.createTms) FROM TbPackageEvent t3 WHERE t3.packageId = t2.packageId) "
                + "AND t2.createTms < :timeThreshold "
                + "AND t2.packageStatus = :packageStatus "
                + "ORDER BY t1.createTms";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("packageStatus", PackageStatus.DELIVERED);
        q.setParameter("timeThreshold", timeThreshold);
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Pair<>((TbPackage) row[0], Arrays.asList((TbPackageEvent) row[1]))).collect(Collectors.toList());
    }

}
