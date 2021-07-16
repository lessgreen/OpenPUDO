package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbPackage;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageDao extends BaseEntityDao<TbPackage, Long> {

    public PackageDao() {
        super(TbPackage.class, "packageId");
    }

}
