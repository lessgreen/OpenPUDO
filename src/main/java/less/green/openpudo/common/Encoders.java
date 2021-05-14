package less.green.openpudo.common;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import java.util.Base64;
import javax.ws.rs.InternalServerErrorException;

public class Encoders {

    public static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    public static final ObjectMapper OBJECT_MAPPER_PRETTY = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);
    public static final Base64.Encoder BASE64_ENCODER = Base64.getEncoder();
    public static final Base64.Decoder BASE64_DECODER = Base64.getDecoder();
    public static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();
    public static final Base64.Decoder BASE64_URL_DECODER = Base64.getUrlDecoder();

    private Encoders() {
    }

    public static String writeValueAsStringSafe(Object obj) {
        try {
            return OBJECT_MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while serializing to JSON", ex);
        }
    }

}
