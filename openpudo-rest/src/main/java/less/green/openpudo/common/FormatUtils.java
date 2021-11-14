package less.green.openpudo.common;

import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;
import lombok.extern.log4j.Log4j2;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Log4j2
public class FormatUtils {

    private static final String PHONENUMBER_REGEX = "^\\+?[0-9 ]{8,}$";
    private static final Pattern PHONENUMBER_PATTERN = Pattern.compile(PHONENUMBER_REGEX);

    private static final PhoneNumberUtil PNU = PhoneNumberUtil.getInstance();

    private FormatUtils() {
    }

    public static String smartElapsed(long elapsedNano) {
        if (elapsedNano < TimeUnit.MICROSECONDS.toNanos(1)) {
            return elapsedNano + " nsec";
        } else if (elapsedNano < TimeUnit.MILLISECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MICROSECONDS.toNanos(1)), elapsedNano < TimeUnit.MICROSECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP) + " usec";
        } else if (elapsedNano < TimeUnit.SECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MILLISECONDS.toNanos(1)), elapsedNano < TimeUnit.MILLISECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP) + " msec";
        } else if (elapsedNano < TimeUnit.MINUTES.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.SECONDS.toNanos(1)), elapsedNano < TimeUnit.SECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP) + " sec";
        } else if (elapsedNano < TimeUnit.HOURS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MINUTES.toNanos(1)), elapsedNano < TimeUnit.MINUTES.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP) + " min";
        } else {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.HOURS.toNanos(1)), elapsedNano < TimeUnit.HOURS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP) + " hours";
        }
    }

    public static String smartElapsed(long elapsedNano, int scale) {
        if (elapsedNano < TimeUnit.MICROSECONDS.toNanos(1)) {
            return elapsedNano + " nsec";
        } else if (elapsedNano < TimeUnit.MILLISECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MICROSECONDS.toNanos(1)), scale, RoundingMode.HALF_UP) + " usec";
        } else if (elapsedNano < TimeUnit.SECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MILLISECONDS.toNanos(1)), scale, RoundingMode.HALF_UP) + " msec";
        } else if (elapsedNano < TimeUnit.MINUTES.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.SECONDS.toNanos(1)), scale, RoundingMode.HALF_UP) + " sec";
        } else if (elapsedNano < TimeUnit.HOURS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MINUTES.toNanos(1)), scale, RoundingMode.HALF_UP) + " min";
        } else {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.HOURS.toNanos(1)), scale, RoundingMode.HALF_UP) + " hours";
        }
    }

    public static String normalizeLoginSafe(String str, String language) {
        // normalizing login
        String login = str.trim();
        // if user is logging in by something like a phone number, try to normalize
        if (PHONENUMBER_PATTERN.matcher(login).matches()) {
            String npn = normalizePhoneNumberSafe(login, language);
            // if it's a valid phone number, we are done, otherwise going on with sanitized original string
            if (npn != null) {
                return npn;
            }
        }
        return login;
    }

    public static String normalizePhoneNumberSafe(String str, String language) {
        if (isEmpty(str)) {
            return null;
        }
        try {
            Phonenumber.PhoneNumber pn;
            if (str.trim().startsWith("+")) {
                // if phone number is already in international format, let the library make hits magic
                pn = PNU.parse(str.trim(), null);
            } else if (isEmpty(language)) {
                // local phone number with no language sent from the client, assuming italian
                pn = PNU.parse(str.trim(), "IT");
            } else {
                pn = PNU.parse(str.trim(), language.toUpperCase());
            }
            if (!PNU.isValidNumber(pn)) {
                return null;
            }
            return PNU.format(pn, PhoneNumberUtil.PhoneNumberFormat.E164);
        } catch (NumberParseException ex) {
            return null;
        }
    }

}
