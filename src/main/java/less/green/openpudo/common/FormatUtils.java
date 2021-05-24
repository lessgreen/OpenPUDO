package less.green.openpudo.common;

import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.concurrent.TimeUnit;
import static less.green.openpudo.common.StringUtils.isEmpty;
import lombok.extern.log4j.Log4j2;

@Log4j2
public class FormatUtils {

    private static final PhoneNumberUtil PNU = PhoneNumberUtil.getInstance();

    private FormatUtils() {
    }

    public static String smartElapsed(long elapsedNano) {
        if (elapsedNano < TimeUnit.MICROSECONDS.toNanos(1)) {
            return Long.toString(elapsedNano) + " nsec";
        } else if (elapsedNano < TimeUnit.MILLISECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MICROSECONDS.toNanos(1)), elapsedNano < TimeUnit.MICROSECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP).toString() + " usec";
        } else if (elapsedNano < TimeUnit.SECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MILLISECONDS.toNanos(1)), elapsedNano < TimeUnit.MILLISECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP).toString() + " msec";
        } else if (elapsedNano < TimeUnit.MINUTES.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.SECONDS.toNanos(1)), elapsedNano < TimeUnit.SECONDS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP).toString() + " sec";
        } else if (elapsedNano < TimeUnit.HOURS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MINUTES.toNanos(1)), elapsedNano < TimeUnit.MINUTES.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP).toString() + " min";
        } else {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.HOURS.toNanos(1)), elapsedNano < TimeUnit.HOURS.toNanos(10) ? 2 : 1, RoundingMode.HALF_UP).toString() + " hours";
        }
    }

    public static String smartElapsed(long elapsedNano, int scale) {
        if (elapsedNano < TimeUnit.MICROSECONDS.toNanos(1)) {
            return Long.toString(elapsedNano) + " nsec";
        } else if (elapsedNano < TimeUnit.MILLISECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MICROSECONDS.toNanos(1)), scale, RoundingMode.HALF_UP).toString() + " usec";
        } else if (elapsedNano < TimeUnit.SECONDS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MILLISECONDS.toNanos(1)), scale, RoundingMode.HALF_UP).toString() + " msec";
        } else if (elapsedNano < TimeUnit.MINUTES.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.SECONDS.toNanos(1)), scale, RoundingMode.HALF_UP).toString() + " sec";
        } else if (elapsedNano < TimeUnit.HOURS.toNanos(1)) {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.MINUTES.toNanos(1)), scale, RoundingMode.HALF_UP).toString() + " min";
        } else {
            return BigDecimal.valueOf(elapsedNano).divide(BigDecimal.valueOf(TimeUnit.HOURS.toNanos(1)), scale, RoundingMode.HALF_UP).toString() + " hours";
        }
    }

    public static String smartSize(long bytes) {
        if (bytes < 1_024L) {
            return Long.toString(bytes) + " byte";
        } else if (bytes < 1_048_576L) {
            return BigDecimal.valueOf(bytes).divide(BigDecimal.valueOf(1_024L), bytes < 10L * 1_024L ? 2 : 1, RoundingMode.HALF_UP).toString() + " KiB";
        } else if (bytes < 1_073_741_824L) {
            return BigDecimal.valueOf(bytes).divide(BigDecimal.valueOf(1_048_576L), bytes < 10L * 1_048_576L ? 2 : 1, RoundingMode.HALF_UP).toString() + " MiB";
        } else if (bytes < 1_099_511_627_776L) {
            return BigDecimal.valueOf(bytes).divide(BigDecimal.valueOf(1_073_741_824L), bytes < 10L * 1_073_741_824L ? 2 : 1, RoundingMode.HALF_UP).toString() + " GiB";
        } else if (bytes < 1_125_899_906_842_624L) {
            return BigDecimal.valueOf(bytes).divide(BigDecimal.valueOf(1_099_511_627_776L), bytes < 10L * 1_099_511_627_776L ? 2 : 1, RoundingMode.HALF_UP).toString() + " TiB";
        } else {
            return BigDecimal.valueOf(bytes).divide(BigDecimal.valueOf(1_125_899_906_842_624L), bytes < 10L * 1_125_899_906_842_624L ? 2 : 1, RoundingMode.HALF_UP).toString() + " PiB";
        }
    }

    public static String safeNormalizePhoneNumber(String str) {
        if (isEmpty(str)) {
            return null;
        }
        try {
            // TODO: proper handling of default country
            Phonenumber.PhoneNumber pn = PNU.parse(str.trim(), "IT");
            if (!PNU.isValidNumber(pn)) {
                return null;
            }
            return PNU.format(pn, PhoneNumberUtil.PhoneNumberFormat.E164);
        } catch (NumberParseException ex) {
            return null;
        }
    }

}
