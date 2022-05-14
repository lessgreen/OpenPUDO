package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.CronLockDao;
import less.green.openpudo.business.model.TbWrkCronLock;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRES_NEW)
@Log4j2
public class CronLockService {

    private static final int EXPIRE_DATE_TIMEUNIT = Calendar.HOUR_OF_DAY;
    private static final int EXPIRE_DATE_AMOUNT = 1;

    @Inject
    CronLockDao cronLockDao;

    public boolean acquireLock(String lockName) {
        if (isEmpty(lockName)) {
            throw new IllegalArgumentException("Empty lock name");
        }

        Calendar cal = GregorianCalendar.getInstance();
        cal.setLenient(false);
        Date now = cal.getTime();
        cal.add(EXPIRE_DATE_TIMEUNIT, EXPIRE_DATE_AMOUNT);
        Date leaseTms = cal.getTime();

        TbWrkCronLock lock = cronLockDao.getLockForUpdate(lockName);
        // if lock does not exist, create it
        if (lock == null) {
            lock = new TbWrkCronLock();
            lock.setLockName(lockName);
            lock.setAcquiredFlag(true);
            lock.setAcquireTms(now);
            lock.setLeaseTms(leaseTms);
            cronLockDao.persist(lock);
            cronLockDao.flush();
            return true;
        }
        // if lock is not held, acquire it
        if (!lock.getAcquiredFlag()) {
            lock.setAcquiredFlag(true);
            lock.setAcquireTms(now);
            lock.setLeaseTms(leaseTms);
            cronLockDao.flush();
            return true;
        }
        // if lock is held but expired, force acquire it
        if (now.after(lock.getLeaseTms())) {
            log.warn("Found expired lock: {}", lockName);
            lock.setAcquiredFlag(true);
            lock.setAcquireTms(now);
            lock.setLeaseTms(leaseTms);
            cronLockDao.flush();
            return true;
        }
        return false;
    }

    public boolean refreshLock(String lockName) {
        if (isEmpty(lockName)) {
            throw new IllegalArgumentException("Empty lock name");
        }

        TbWrkCronLock lock = cronLockDao.getLockForUpdate(lockName);
        if (lock == null) {
            log.warn("Trying to refresh a non existing lock: {}", lockName);
            return false;
        }
        if (!lock.getAcquiredFlag()) {
            log.warn("Trying to refresh a non held lock: {}", lockName);
            return false;
        }

        Calendar cal = GregorianCalendar.getInstance();
        cal.setLenient(false);
        cal.add(EXPIRE_DATE_TIMEUNIT, EXPIRE_DATE_AMOUNT);
        Date leaseTms = cal.getTime();

        lock.setLeaseTms(leaseTms);
        cronLockDao.flush();
        return true;
    }

    public boolean releaseLock(String lockName) {
        if (isEmpty(lockName)) {
            throw new IllegalArgumentException("Empty lock name");
        }

        TbWrkCronLock lock = cronLockDao.getLockForUpdate(lockName);
        if (lock == null) {
            log.warn("Trying to release a non existing lock: {}", lockName);
            return false;
        }
        if (!lock.getAcquiredFlag()) {
            log.warn("Trying to release a non held lock: {}", lockName);
            return false;
        }

        lock.setAcquiredFlag(false);
        cronLockDao.flush();
        return true;
    }

}
