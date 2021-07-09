package less.green.openpudo.common;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class Constants {

    public static final String PROFILE_PIC_MULTIPART_NAME = "foto";
    public static final Set<String> ALLOWED_IMAGE_MIME_TYPES = new HashSet<>(Arrays.asList(
            "image/jpeg",
            "image/png",
            "image/gif"
    ));

    private Constants() {
    }

}
