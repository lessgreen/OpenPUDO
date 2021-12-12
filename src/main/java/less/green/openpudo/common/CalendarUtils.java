package less.green.openpudo.common;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

public class CalendarUtils {

    private static final String SDF_PATTERN = "dd/MM/yyyy HH:mm:ss.SSS";
    private static final String SDF_PATTERN_TZ = "dd/MM/yyyy HH:mm:ss.SSS z";

    private CalendarUtils() {
    }

    public static Calendar getCalendar() {
        Calendar cal = GregorianCalendar.getInstance();
        cal.setLenient(false);
        return cal;
    }

    public static String formatDate(Date d) {
        SimpleDateFormat sdf = new SimpleDateFormat(SDF_PATTERN);
        return sdf.format(d);
    }

    public static String formatDateTz(Date d) {
        SimpleDateFormat sdf = new SimpleDateFormat(SDF_PATTERN_TZ);
        return sdf.format(d);
    }

}
