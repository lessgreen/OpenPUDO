package less.green.openpudo.business.model.usertype;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import less.green.openpudo.common.Encoders;

import javax.persistence.AttributeConverter;
import java.util.Map;

public class JsonConverter implements AttributeConverter<Map<String, Object>, String> {

    @Override
    public String convertToDatabaseColumn(Map<String, Object> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return null;
        }
        try {
            return Encoders.OBJECT_MAPPER.writeValueAsString(attribute);
        } catch (JsonProcessingException ex) {
            throw new IllegalArgumentException("Error while serializing to JSON", ex);
        }
    }

    @Override
    public Map<String, Object> convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        try {
            return Encoders.OBJECT_MAPPER.readValue(dbData, new TypeReference<>() {
            });
        } catch (JsonProcessingException ex) {
            throw new IllegalArgumentException("Illegal JSON column on database", ex);
        }
    }

}
