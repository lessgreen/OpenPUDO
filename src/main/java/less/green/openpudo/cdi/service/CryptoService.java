package less.green.openpudo.cdi.service;

import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import javax.enterprise.context.ApplicationScoped;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;

@ApplicationScoped
@Log4j2
public class CryptoService {

    private static final String MAC_ALGORITHM = "HmacSHA512";

    @ConfigProperty(name = "app.secret")
    String appSecret;

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

}
