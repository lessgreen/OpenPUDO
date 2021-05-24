package less.green.openpudo.cdi.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.TimeZone;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.enterprise.context.ApplicationScoped;
import less.green.openpudo.common.Encoders;
import static less.green.openpudo.common.Encoders.BASE64_URL_DECODER;
import static less.green.openpudo.common.Encoders.BASE64_URL_ENCODER;
import static less.green.openpudo.common.Encoders.OBJECT_MAPPER;
import less.green.openpudo.common.dto.JwtHeader;
import less.green.openpudo.common.dto.JwtPayload;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
@Log4j2
public class JwtService {

    private static final String MAC_ALGORITHM = "HmacSHA512";
    private static final String HEADER_ALG = "HS512";
    private static final String HEADER_TYP = "JWT";
    private static final String PAYLOAD_ISS = "OpenPUDO";
    private static final JwtHeader HEADER_INSTANCE = new JwtHeader(HEADER_ALG, HEADER_TYP);
    private static final String HEADER_INSTANCE_JSON = Encoders.writeValueAsStringSafe(HEADER_INSTANCE);
    private static final String HEADER_INSTANCE_JSON_BASE64 = BASE64_URL_ENCODER.encodeToString(HEADER_INSTANCE_JSON.getBytes(StandardCharsets.UTF_8));
    private static final TimeZone UTC = TimeZone.getTimeZone("UTC");
    private static final int EXPIRE_DATE_TIMEUNIT = Calendar.MONTH;
    private static final int EXPIRE_DATE_AMOUNT = 1;

    @ConfigProperty(name = "jwt.secret")
    String jwtSecret;

    public JwtPayload generatePayload(Long userId) {
        Calendar cal = GregorianCalendar.getInstance(UTC);
        cal.setLenient(false);
        Date iat = cal.getTime();
        cal.add(EXPIRE_DATE_TIMEUNIT, EXPIRE_DATE_AMOUNT);
        Date exp = cal.getTime();
        return new JwtPayload(PAYLOAD_ISS, userId, iat, exp);
    }

    public String generateAccessToken(JwtPayload payload) {
        String payloadJson = Encoders.writeValueAsStringSafe(payload);
        String payloadJsonBase64 = BASE64_URL_ENCODER.encodeToString(payloadJson.getBytes(StandardCharsets.UTF_8));

        Mac mac = createMac();
        byte[] signatureBytes = mac.doFinal((HEADER_INSTANCE_JSON_BASE64 + "." + payloadJsonBase64).getBytes(StandardCharsets.UTF_8));
        String signatureBase64 = BASE64_URL_ENCODER.encodeToString(signatureBytes);

        String accessToken = HEADER_INSTANCE_JSON_BASE64 + "." + payloadJsonBase64 + "." + signatureBase64;
        return accessToken;
    }

    public boolean verifyAccessTokenSignature(String candidateToken) {
        String[] split = candidateToken.split("\\.", -1);
        if (split.length != 3) {
            return false;
        }
        Mac mac = createMac();
        byte[] signatureBytes = mac.doFinal((split[0] + "." + split[1]).getBytes(StandardCharsets.UTF_8));
        String signatureBase64 = BASE64_URL_ENCODER.encodeToString(signatureBytes);
        return signatureBase64.equals(split[2]);
    }

    public JwtPayload decodePayload(String payloadJsonBase64) throws JsonProcessingException {
        String payloadJson = new String(BASE64_URL_DECODER.decode(payloadJsonBase64), StandardCharsets.UTF_8);
        JwtPayload payload = OBJECT_MAPPER.readValue(payloadJson, JwtPayload.class);
        return payload;
    }

    private Mac createMac() {
        Mac mac;
        try {
            mac = Mac.getInstance(MAC_ALGORITHM);
        } catch (NoSuchAlgorithmException ex) {
            // hopefully unreachable code
            throw new AssertionError("Unsupported MAC algorithm: " + MAC_ALGORITHM, ex);
        }
        SecretKeySpec key = new SecretKeySpec(jwtSecret.getBytes(StandardCharsets.UTF_8), MAC_ALGORITHM);
        try {
            mac.init(key);
        } catch (InvalidKeyException ex) {
            // hopefully unreachable code
            throw new AssertionError("Invalid SecretKeySpec", ex);
        }
        return mac;
    }

}
