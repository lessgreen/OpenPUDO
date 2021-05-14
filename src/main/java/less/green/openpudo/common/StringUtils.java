package less.green.openpudo.common;

import lombok.extern.log4j.Log4j2;

@Log4j2
public class StringUtils {

    private StringUtils() {
    }

    public static boolean isEmpty(String str) {
        return str == null || str.trim().equals("");
    }

    public static String sanitizeString(String str) {
        return isEmpty(str) ? null : str.trim();
    }

}
