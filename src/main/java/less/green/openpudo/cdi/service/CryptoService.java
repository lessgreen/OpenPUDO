package less.green.openpudo.cdi.service;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Map;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.enterprise.context.ApplicationScoped;
import less.green.openpudo.common.Encoders;
import static less.green.openpudo.common.Encoders.BASE64_DECODER;
import static less.green.openpudo.common.Encoders.BASE64_ENCODER;
import less.green.openpudo.common.dto.AccountSecret;
import lombok.extern.log4j.Log4j2;

@ApplicationScoped
@Log4j2
public class CryptoService {

    private static final String DEFAULT_KEY_DERIVATIVE_FUNCTION = "PBKDF2WithHmacSHA512";
    private static final int DEFAULT_KEY_LENGTH_BIT = 512;
    private static final int DEFAULT_SALT_LENGTH_BYTE = DEFAULT_KEY_LENGTH_BIT / 8;
    private static final int DEFAULT_ITERATIONS = 10_000;
    private static final Map<String, String> DEFAULT_SECRET_SPECS = Map.of(
            "key_derivative_function", DEFAULT_KEY_DERIVATIVE_FUNCTION,
            "key_length_bit", Integer.toString(DEFAULT_KEY_LENGTH_BIT),
            "salt_length_byte", Integer.toString(DEFAULT_SALT_LENGTH_BYTE),
            "iterations", Integer.toString(DEFAULT_ITERATIONS)
    );
    private static final String DEFAULT_SECRET_SPECS_JSON = Encoders.writeValueAsStringSafe(DEFAULT_SECRET_SPECS);

    private final SecureRandom rand = new SecureRandom();

    public AccountSecret generateAccountSecret(String password) {
        byte[] saltBytes = genSalt(DEFAULT_SALT_LENGTH_BYTE);
        byte[] passwordHashBytes = genPasswordHash(saltBytes, password);
        String saltBase64 = BASE64_ENCODER.encodeToString(saltBytes);
        String passwordHashBase64 = BASE64_ENCODER.encodeToString(passwordHashBytes);
        // we generate and store secret specs for future security improvements
        return new AccountSecret(saltBase64, passwordHashBase64, DEFAULT_SECRET_SPECS_JSON);
    }

    private byte[] genSalt(int length) {
        byte[] salt = new byte[length];
        rand.nextBytes(salt);
        return salt;
    }

    private byte[] genPasswordHash(byte[] salt, String password) {
        SecretKeyFactory skf;
        try {
            skf = SecretKeyFactory.getInstance(DEFAULT_KEY_DERIVATIVE_FUNCTION);
        } catch (NoSuchAlgorithmException ex) {
            // hopefully unreachable code
            throw new AssertionError("Unsupported key derivative function: " + DEFAULT_KEY_DERIVATIVE_FUNCTION, ex);
        }
        PBEKeySpec keySpec = new PBEKeySpec(password.toCharArray(), salt, DEFAULT_ITERATIONS, DEFAULT_KEY_LENGTH_BIT);
        byte[] hash;
        try {
            hash = skf.generateSecret(keySpec).getEncoded();
        } catch (InvalidKeySpecException ex) {
            // hopefully unreachable code
            throw new AssertionError("Invalid PBEKeySpec", ex);
        }
        return hash;
    }

    public boolean verifyPasswordHash(AccountSecret secret, String candidatePassword) {
        // we assume default secret specs at the moment, but in the future we might support different specs
        byte[] saltBytes = BASE64_DECODER.decode(secret.getSaltBase64());
        byte[] candidatePasswordHashBytes = genPasswordHash(saltBytes, candidatePassword);
        String candidatePasswordHashBase64 = BASE64_ENCODER.encodeToString(candidatePasswordHashBytes);
        return secret.getPasswordHashBase64().equals(candidatePasswordHashBase64);
    }

}
