package less.green.openpudo.common;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;

import javax.ws.rs.InternalServerErrorException;
import java.util.Base64;
import java.util.Map;

public class Encoders {

    public static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    public static final ObjectMapper OBJECT_MAPPER_COMPACT = new ObjectMapper().setSerializationInclusion(JsonInclude.Include.NON_NULL);
    public static final ObjectMapper OBJECT_MAPPER_PRETTY = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT);
    public static final ObjectMapper OBJECT_MAPPER_PRETTY_COMPACT = new ObjectMapper().enable(SerializationFeature.INDENT_OUTPUT).setSerializationInclusion(JsonInclude.Include.NON_NULL);
    public static final Base64.Encoder BASE64_ENCODER = Base64.getEncoder();
    public static final Base64.Decoder BASE64_DECODER = Base64.getDecoder();
    public static final Base64.Encoder BASE64_URL_ENCODER = Base64.getUrlEncoder().withoutPadding();
    public static final Base64.Decoder BASE64_URL_DECODER = Base64.getUrlDecoder();

    private Encoders() {
    }

    public static String writeJson(Object obj) {
        try {
            return OBJECT_MAPPER.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while serializing to JSON", ex);
        }
    }

    public static String writeJsonCompact(Object obj) {
        try {
            return OBJECT_MAPPER_COMPACT.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while serializing to JSON", ex);
        }
    }

    public static String writeJsonPretty(Object obj) {
        try {
            return OBJECT_MAPPER_PRETTY.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while serializing to JSON", ex);
        }
    }

    public static String writeJsonCompactPretty(Object obj) {
        try {
            return OBJECT_MAPPER_PRETTY_COMPACT.writeValueAsString(obj);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while serializing to JSON", ex);
        }
    }

    public static Map<String, Object> readJsonAsMap(String str) {
        try {
            return Encoders.OBJECT_MAPPER.readValue(str, new TypeReference<>() {
            });
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while deserializing from JSON as map", ex);
        }
    }

    public static String[] readJsonAsStringArray(String str) {
        try {
            return Encoders.OBJECT_MAPPER.readValue(str, String[].class);
        } catch (JsonProcessingException ex) {
            throw new InternalServerErrorException("Error while deserializing from JSON as string array", ex);
        }
    }

}
