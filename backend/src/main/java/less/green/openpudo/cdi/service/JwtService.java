package less.green.openpudo.cdi.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.quarkus.runtime.Startup;
import less.green.openpudo.common.CalendarUtils;
import less.green.openpudo.common.dto.jwt.*;
import lombok.extern.log4j.Log4j2;

import javax.crypto.Mac;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.nio.charset.StandardCharsets;
import java.util.Calendar;
import java.util.Date;

import static less.green.openpudo.common.Encoders.*;

@ApplicationScoped
@Startup
@Log4j2
public class JwtService {

    private static final String HEADER_INSTANCE_JSON = dumpJson(new JwtHeader());
    private static final String HEADER_INSTANCE_JSON_BASE64 = BASE64_URL_ENCODER.encodeToString(HEADER_INSTANCE_JSON.getBytes(StandardCharsets.UTF_8));

    private static final int EXPIRE_DATE_LONG_TIMEUNIT = Calendar.MONTH;
    private static final int EXPIRE_DATE_LONG_AMOUNT = 1;
    private static final int EXPIRE_DATE_SHORT_TIMEUNIT = Calendar.HOUR_OF_DAY;
    private static final int EXPIRE_DATE_SHORT_AMOUNT = 1;

    @Inject
    CryptoService cryptoService;

    public AccessTokenData generateUserTokenData(Long userId, AccessProfile profile) {
        Calendar cal = CalendarUtils.getCalendar();
        Date iat = cal.getTime();
        cal.add(EXPIRE_DATE_LONG_TIMEUNIT, EXPIRE_DATE_LONG_AMOUNT);
        Date exp = cal.getTime();
        JwtPayload payload = new JwtPayload(userId, iat, exp, null);
        String accessToken = generateAccessToken(payload);
        return new AccessTokenData(accessToken, profile, iat, exp);
    }

    public AccessTokenData generateGuestTokenData(JwtPrivateClaims privateClaims) {
        Calendar cal = CalendarUtils.getCalendar();
        Date iat = cal.getTime();
        cal.add(EXPIRE_DATE_SHORT_TIMEUNIT, EXPIRE_DATE_SHORT_AMOUNT);
        Date exp = cal.getTime();
        JwtPayload payload = new JwtPayload(null, iat, exp, privateClaims);
        String accessToken = generateAccessToken(payload);
        return new AccessTokenData(accessToken, AccessProfile.GUEST, iat, exp);
    }

    private String generateAccessToken(JwtPayload payload) {
        String payloadJson = dumpJson(payload);
        String payloadJsonBase64 = BASE64_URL_ENCODER.encodeToString(payloadJson.getBytes(StandardCharsets.UTF_8));

        Mac mac = cryptoService.createMac();
        byte[] signatureBytes = mac.doFinal((HEADER_INSTANCE_JSON_BASE64 + "." + payloadJsonBase64).getBytes(StandardCharsets.UTF_8));
        String signatureBase64 = BASE64_URL_ENCODER.encodeToString(signatureBytes);

        return HEADER_INSTANCE_JSON_BASE64 + "." + payloadJsonBase64 + "." + signatureBase64;
    }

    public boolean isValidSignature(String candidateToken) {
        String[] split = candidateToken.split("\\.", -1);
        if (split.length != 3) {
            return false;
        }
        Mac mac = cryptoService.createMac();
        byte[] signatureBytes = mac.doFinal((split[0] + "." + split[1]).getBytes(StandardCharsets.UTF_8));
        String signatureBase64 = BASE64_URL_ENCODER.encodeToString(signatureBytes);
        return signatureBase64.equals(split[2]);
    }

    public JwtPayload decodePayload(String payloadJsonBase64) throws JsonProcessingException {
        String payloadJson = new String(BASE64_URL_DECODER.decode(payloadJsonBase64), StandardCharsets.UTF_8);
        return OBJECT_MAPPER.readValue(payloadJson, JwtPayload.class);
    }

}
