package less.green.openpudo.cdi.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.quarkus.runtime.Startup;
import less.green.openpudo.common.dto.jwt.*;
import lombok.extern.log4j.Log4j2;

import javax.crypto.Mac;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import static less.green.openpudo.common.Encoders.*;

@ApplicationScoped
@Startup
@Log4j2
public class JwtService {

    private static final String HEADER_INSTANCE_JSON = writeJson(new JwtHeader());
    private static final String HEADER_INSTANCE_JSON_BASE64 = BASE64_URL_ENCODER.encodeToString(HEADER_INSTANCE_JSON.getBytes(StandardCharsets.UTF_8));

    private static final Duration EXPIRE_LONG_DURATION = Duration.of(30, ChronoUnit.DAYS);
    private static final Duration EXPIRE_SHORT_DURATION = Duration.of(1, ChronoUnit.DAYS);

    @Inject
    CryptoService cryptoService;

    public AccessTokenData generateUserTokenData(Long userId, AccessProfile profile) {
        Instant iat = Instant.now();
        Instant exp = iat.plus(EXPIRE_LONG_DURATION);
        JwtPayload payload = new JwtPayload(userId, iat, exp, null);
        String accessToken = generateAccessToken(payload);
        return new AccessTokenData(accessToken, profile, iat, exp);
    }

    public AccessTokenData generateGuestTokenData(JwtPrivateClaims privateClaims) {
        Instant iat = Instant.now();
        Instant exp = iat.plus(EXPIRE_SHORT_DURATION);
        JwtPayload payload = new JwtPayload(null, iat, exp, privateClaims);
        String accessToken = generateAccessToken(payload);
        return new AccessTokenData(accessToken, AccessProfile.GUEST, iat, exp);
    }

    private String generateAccessToken(JwtPayload payload) {
        String payloadJson = writeJson(payload);
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
