package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.model.TbPackageEvent;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class PackageEventDao extends BaseEntityDao<TbPackageEvent, Long> {

    public PackageEventDao() {
        super(TbPackageEvent.class, "packageEventId");
    }

}
