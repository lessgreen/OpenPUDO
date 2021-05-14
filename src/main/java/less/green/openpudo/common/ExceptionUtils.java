package less.green.openpudo.common;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

public class ExceptionUtils {

    private ExceptionUtils() {
    }

    public static String getCanonicalForm(Throwable throwable) {
        return throwable.getClass().getSimpleName() + ": " + throwable.getMessage();
    }

    public static String getCanonicalFormWithRootCause(Throwable throwable, Throwable rootCause) {
        return getCanonicalForm(throwable) + " [caused by " + getCanonicalForm(rootCause) + "]";
    }

    public static String getCanonicalFormWithRootCause(Throwable throwable) {
        Throwable rootCause = getRootCause(throwable);
        if (rootCause != null && rootCause != throwable) {
            return getCanonicalFormWithRootCause(throwable, rootCause);
        }
        return getCanonicalForm(throwable);
    }

    public static List<Throwable> getThrowableList(Throwable throwable) {
        List<Throwable> list = new LinkedList<>();
        while (throwable != null && !list.contains(throwable)) {
            list.add(throwable);
            throwable = throwable.getCause();
        }
        return list.isEmpty() ? Collections.emptyList() : list;
    }

    public static Throwable getRootCause(Throwable throwable) {
        List<Throwable> list = getThrowableList(throwable);
        return list.isEmpty() ? null : list.get(list.size() - 1);
    }

    public static String getStackTrace(Throwable throwable) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        throwable.printStackTrace(pw);
        return sw.toString();
    }

    public static String getCompactStackTrace(Throwable throwable) {
        return getCompactStackTrace(throwable, Arrays.asList("less.green.openpudo"));
    }

    public static String getCompactStackTrace(Throwable throwable, String prefix) {
        return getCompactStackTrace(throwable, Arrays.asList(prefix));
    }

    public static String getCompactStackTrace(Throwable throwable, List<String> prefixes) {
        String stackTrace = getStackTrace(throwable);
        String lines[] = stackTrace.split("\\r?\\n");
        String ret = Arrays.stream(lines)
                .filter(i -> !i.startsWith("\t")
                || prefixes.stream().anyMatch(pr -> !i.contains("$") && (i.contains("at " + pr + ".") || (i.contains("at ") && i.contains("/" + pr + ".")))))
                .collect(Collectors.joining("\n"));
        return ret;
    }

}
