package less.green.openpudo.common;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

public class StreamUtils {

    private static final int BUFFER_SIZE = 8 * 1024;

    private StreamUtils() {
    }

    public static byte[] readAllBytesFromInputStream(InputStream is) throws IOException {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream(BUFFER_SIZE)) {
            byte[] buffer = new byte[BUFFER_SIZE];
            int read;
            while ((read = is.read(buffer, 0, buffer.length)) != -1) {
                baos.write(buffer, 0, read);
            }
            return baos.toByteArray();
        }
    }

    public static String inputStreamToString(InputStream is) throws IOException {
        byte[] bytes = readAllBytesFromInputStream(is);
        if (bytes.length == 0) {
            return null;
        }
        return new String(bytes, StandardCharsets.UTF_8);
    }

}
