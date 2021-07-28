package less.green.openpudo.persistence.dao;

import java.util.Arrays;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageDao extends BaseEntityDao<TbPackage, Long> {

    public PackageDao() {
        super(TbPackage.class, "packageId");
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
        return rs == null ? null : new Pair<>((TbPackage) rs[0], Arrays.asList((TbPackageEvent) rs[2]));
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

}
