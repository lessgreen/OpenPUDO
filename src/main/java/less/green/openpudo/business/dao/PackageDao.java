package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.PackageStatus;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.common.dto.tuple.Sextet;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
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

    public long getActivePackageCount(Long pudoId, Long userId) {
        String qs = "SELECT COUNT(*) "
                    + "FROM TbPackage t1, TbPackageEvent t2 "
                    + "WHERE t1.packageId = t2.packageId "
                    + "AND t2.createTms = (SELECT MAX(st2.createTms) FROM TbPackageEvent st2 WHERE st2.packageId = t2.packageId) "
                    + "AND t1.pudoId = :pudoId "
                    + "AND t1.userId = :userId "
                    + "AND t2.packageStatus IN :packageStatusList";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("pudoId", pudoId);
        q.setParameter("userId", userId);
        q.setParameter("packageStatusList", Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED, PackageStatus.COLLECTED));
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

    public List<Sextet<TbPackage, TbPackageEvent, TbPudo, TbAddress, TbUserProfile, TbUserPudoRelation>> getPackages(AccountType accountType, Long referenceId, List<PackageStatus> packageStatuses, boolean history, int limit, int offset) {
        String qs = "SELECT t1, t2, t3, t4, t5, t6 "
                    + "FROM TbPackage t1, TbPackageEvent t2, TbPudo t3, TbAddress t4, TbUserProfile t5, TbUserPudoRelation t6 "
                    // join with event, select the latest
                    + "WHERE t2.packageId = t1.packageId "
                    + "AND t2.createTms = (SELECT MAX(st2.createTms) FROM TbPackageEvent st2 WHERE st2.packageId = t2.packageId) "
                    // join with pudo and address
                    + "AND t3.pudoId = t1.pudoId "
                    + "AND t4.pudoId = t1.pudoId "
                    // join with user profile
                    + "AND t5.userId = t1.userId "
                    // join with latest user-pudo relation, no matter if closed or not
                    + "AND t6.userId = t1.userId AND t6.pudoId = t1.pudoId AND t6.relationType = :relationType "
                    + "AND t6.createTms = (SELECT MAX(st6.createTms) FROM TbUserPudoRelation st6 WHERE st6.userId = t6.userId AND st6.pudoId = t6.pudoId AND st6.relationType = t6.relationType) ";
        if (accountType == AccountType.CUSTOMER) {
            qs += "AND t1.userId = :referenceId ";
        } else if (accountType == AccountType.PUDO) {
            qs += "AND t1.pudoId = :referenceId ";
        } else {
            throw new AssertionError("Unsupported AccountType: " + accountType);
        }
        if (packageStatuses != null && !packageStatuses.isEmpty()) {
            qs += "AND t2.packageStatus IN :packageStatuses ";
        }
        qs += "ORDER BY t1.createTms DESC";
        TypedQuery<Object[]> q = em.createQuery(qs, Object[].class);
        q.setParameter("referenceId", referenceId);
        q.setParameter("relationType", RelationType.CUSTOMER);
        if (packageStatuses != null && !packageStatuses.isEmpty()) {
            q.setParameter("packageStatuses", packageStatuses);
        }
        if (history) {
            q.setMaxResults(limit);
            q.setFirstResult(offset);
        }
        List<Object[]> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs.stream().map(row -> new Sextet<>((TbPackage) row[0], (TbPackageEvent) row[1], (TbPudo) row[2], (TbAddress) row[3], (TbUserProfile) row[4], (TbUserPudoRelation) row[5])).collect(Collectors.toList());
    }

    public List<Long> getPackageIdsToNotifySent(Date timeThreshold) {
        String qs = "SELECT t1.packageId "
                    + "FROM TbPackage t1, TbPackageEvent t2 "
                    + "WHERE t2.packageId = t1.packageId "
                    + "AND t2.createTms = (SELECT MAX(st2.createTms) FROM TbPackageEvent st2 WHERE st2.packageId = t2.packageId) "
                    + "AND t2.createTms < :timeThreshold "
                    + "AND t2.packageStatus = :packageStatus "
                    + "ORDER BY t1.createTms";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("timeThreshold", timeThreshold);
        q.setParameter("packageStatus", PackageStatus.DELIVERED);
        List<Long> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public List<Long> getPackageIdsToExpired(Date timeThreshold) {
        String qs = "SELECT t1.packageId "
                    + "FROM TbPackage t1, TbPackageEvent t2 "
                    + "WHERE t2.packageId = t1.packageId "
                    + "AND t2.createTms = (SELECT MAX(st2.createTms) FROM TbPackageEvent st2 WHERE st2.packageId = t2.packageId) "
                    + "AND t1.createTms < :timeThreshold "
                    + "AND t2.packageStatus IN :packageStatuses "
                    + "ORDER BY t1.createTms";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("timeThreshold", timeThreshold);
        q.setParameter("packageStatuses", Arrays.asList(PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED));
        List<Long> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public List<Long> getPackageIdsToAccepted(Date timeThreshold) {
        String qs = "SELECT t1.packageId "
                    + "FROM TbPackage t1, TbPackageEvent t2 "
                    + "WHERE t2.packageId = t1.packageId "
                    + "AND t2.createTms = (SELECT MAX(st2.createTms) FROM TbPackageEvent st2 WHERE st2.packageId = t2.packageId) "
                    + "AND t2.createTms < :timeThreshold "
                    + "AND t2.packageStatus = :packageStatus "
                    + "ORDER BY t1.createTms";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("timeThreshold", timeThreshold);
        q.setParameter("packageStatus", PackageStatus.COLLECTED);
        List<Long> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
