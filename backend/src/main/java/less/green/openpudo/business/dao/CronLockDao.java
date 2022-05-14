package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbWrkCronLock;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.LockModeType;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class CronLockDao extends BaseEntityDao<TbWrkCronLock, String> {

    public CronLockDao() {
        super(TbWrkCronLock.class, "lockName");
    }

    public TbWrkCronLock getLockForUpdate(String lockName) {
        return em.find(TbWrkCronLock.class, lockName, LockModeType.PESSIMISTIC_WRITE);
    }

}
