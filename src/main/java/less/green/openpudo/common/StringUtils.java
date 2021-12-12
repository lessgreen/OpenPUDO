package less.green.openpudo.common;

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
