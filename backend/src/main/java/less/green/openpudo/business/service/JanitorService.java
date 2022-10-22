package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.DeviceTokenDao;
import less.green.openpudo.business.dao.ExternalFileDao;
import less.green.openpudo.business.dao.GooglePlacesSessionDao;
import less.green.openpudo.business.dao.OtpRequestDao;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Set;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class JanitorService {

    @Inject
    DeviceTokenDao deviceTokenDao;
    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    GooglePlacesSessionDao googlePlacesSessionDao;
    @Inject
    OtpRequestDao otpRequestDao;

    public int removeExpiredOtpRequests() {
        // remove OTP requests being stale for more than 1 day
        Instant timeThreshold = Instant.now().minus(1, ChronoUnit.DAYS);
        return otpRequestDao.removeExpiredOtpRequests(timeThreshold);
    }

    public int removeFailedDeviceTokens() {
        // remove device tokens that have failed for 10 or more times
        return deviceTokenDao.removeFailedDeviceTokens();
    }

    public Set<String> getAllStoredFiles() {
        return externalFileDao.getAllStoredFiles();
    }

    public int removeExpiredGooglePlacesSessions() {
        // remove Google Places session being stale for more than 10 minutes
        Instant timeThreshold = Instant.now().minus(10, ChronoUnit.MINUTES);
        return googlePlacesSessionDao.removeExpiredGooglePlacesSessions(timeThreshold);
    }

}
