package less.green.openpudo.common;

import com.google.i18n.phonenumbers.NumberParseException;
import com.google.i18n.phonenumbers.PhoneNumberUtil;
import com.google.i18n.phonenumbers.Phonenumber;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import static less.green.openpudo.common.StringUtils.isEmpty;

public class PhoneNumberUtils {

    private static final PhoneNumberUtil PNU = PhoneNumberUtil.getInstance();

    public PhoneNumberUtils() {
    }

    public static PhoneNumberSummary normalizePhoneNumber(String str) {
        if (isEmpty(str)) {
            return new PhoneNumberSummary(false, false, null);
        }
        Phonenumber.PhoneNumber pn;
        try {
            pn = PNU.parse(str.trim(), null);
        } catch (NumberParseException ex) {
            return new PhoneNumberSummary(false, false, null);
        }
        PhoneNumberSummary ret = new PhoneNumberSummary();
        ret.setValid(PNU.isValidNumber(pn));
        ret.setMobile(PNU.getNumberType(pn) == PhoneNumberUtil.PhoneNumberType.MOBILE || PNU.getNumberType(pn) == PhoneNumberUtil.PhoneNumberType.FIXED_LINE_OR_MOBILE);
        ret.setNormalizedPhoneNumber(PNU.format(pn, PhoneNumberUtil.PhoneNumberFormat.E164));
        return ret;
    }

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PhoneNumberSummary {

        private boolean valid;
        private boolean mobile;
        private String normalizedPhoneNumber;

    }
}
