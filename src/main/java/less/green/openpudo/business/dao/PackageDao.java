package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbPackage;

import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageDao extends BaseEntityDao<TbPackage, Long> {

    public PackageDao() {
        super(TbPackage.class, "packageId");
    }

    public long getPackageCountForCustomer(Long userId) {
        String qs = "SELECT COUNT(*) FROM TbPackage t WHERE t.userId = :userId ";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        return q.getSingleResult();
    }

    public long getPackageCountForPudo(Long pudoId) {
        String qs = "SELECT COUNT(*) FROM TbPackage t WHERE t.pudoId = :pudoId ";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("pudoId", pudoId);
        return q.getSingleResult();
    }

}
