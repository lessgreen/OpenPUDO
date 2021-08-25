package less.green.openpudo.common;

import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import less.green.openpudo.common.dto.tuple.Pair;
import org.jboss.resteasy.plugins.providers.multipart.InputPart;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

public class MultipartUtils {

    public static final String MULTIPART_NAME = "attachment";

    public static final Set<String> ALLOWED_IMAGE_MIME_TYPES = new HashSet<>(Arrays.asList(
            "image/jpeg",
            "image/png",
            "image/gif"
    ));

    private MultipartUtils() {
    }

    public static Pair<String, byte[]> readUploadedFile(MultipartFormDataInput req) throws IOException {
        if (req == null) {
            return null;
        }
        Map<String, List<InputPart>> map = req.getFormDataMap();
        List<InputPart> parts = map.get(MULTIPART_NAME);
        if (parts == null || parts.isEmpty()) {
            return null;
        }
        InputPart part = parts.get(0);
        String mimeType = part.getMediaType().toString();
        mimeType = mimeType.split(";", -1)[0];
        byte[] bytes;
        try (InputStream is = part.getBody(InputStream.class, null)) {
            bytes = StreamUtils.readAllBytesFromInputStream(is);
        }
        return new Pair<>(mimeType, bytes);
    }

}
