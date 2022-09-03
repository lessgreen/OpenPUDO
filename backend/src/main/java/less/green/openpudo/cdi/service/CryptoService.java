package less.green.openpudo.cdi.service;

import io.quarkus.runtime.Startup;
import less.green.openpudo.common.Encoders;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.hashids.Hashids;

import javax.annotation.PostConstruct;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.enterprise.context.ApplicationScoped;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

@ApplicationScoped
@Startup
@Log4j2
public class CryptoService {

    private static final String MAC_ALGORITHM = "HmacSHA512";
    private static final String HASHIDS_ALPHABET_SHORT = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    private static final String HASHIDS_ALPHABET_LONG = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    @ConfigProperty(name = "app.secret")
    String appSecret;

    private Hashids hashidsShort;
    private Hashids hashidsLong;

    @PostConstruct
    void init() {
        hashidsShort = new Hashids(appSecret, 6, HASHIDS_ALPHABET_SHORT);
        hashidsLong = new Hashids(appSecret, 20, HASHIDS_ALPHABET_LONG);
    }

    public Mac createMac() {
        Mac mac;
        try {
            mac = Mac.getInstance(MAC_ALGORITHM);
        } catch (NoSuchAlgorithmException ex) {
            // hopefully unreachable code
            throw new AssertionError("Unsupported MAC algorithm: " + MAC_ALGORITHM, ex);
        }
        SecretKeySpec key = new SecretKeySpec(appSecret.getBytes(StandardCharsets.UTF_8), MAC_ALGORITHM);
        try {
            mac.init(key);
        } catch (InvalidKeyException ex) {
            // hopefully unreachable code
            throw new AssertionError("Invalid SecretKeySpec", ex);
        }
        return mac;
    }

    public String signObject(Object obj) {
        Mac mac = createMac();
        String json = Encoders.dumpJson(obj);
        byte[] signature = mac.doFinal(json.getBytes(StandardCharsets.UTF_8));
        return Encoders.BASE64_URL_ENCODER.encodeToString(signature);
    }

    public boolean isValidSignature(Object obj, String candidateSignature) {
        String signature = signObject(obj);
        return signature.equals(candidateSignature);
    }

    public String hashidEncodeShort(Long l) {
        return hashidsShort.encode(l);
    }

    public String hashidEncodeLong(Long l) {
        return hashidsLong.encode(l);
    }

    public Long hashidDecodeLong(String s) {
        long[] decoded = hashidsLong.decode(s);
        if (decoded.length == 0) {
            return null;
        }
        return decoded[0];
    }

}
