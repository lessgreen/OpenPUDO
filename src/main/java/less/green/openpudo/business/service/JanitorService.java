package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.OtpRequestDao;
import less.green.openpudo.common.CalendarUtils;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Calendar;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class JanitorService {

    @Inject
    OtpRequestDao otpRequestDao;

    public int removeExpiredOtpRequests() {
        // remove OTP requests being stale for more than 24 hours
        Calendar cal = CalendarUtils.getCalendar();
        cal.add(Calendar.HOUR_OF_DAY, -24);
        return otpRequestDao.removeExpiredOtpRequests(cal.getTime());
    }

}
