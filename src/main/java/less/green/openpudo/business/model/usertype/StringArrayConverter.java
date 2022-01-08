package less.green.openpudo.business.model.usertype;

import com.fasterxml.jackson.core.JsonProcessingException;
import less.green.openpudo.common.Encoders;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class StringArrayConverter implements AttributeConverter<String[], String> {

    @Override
    public String convertToDatabaseColumn(String[] attribute) {
        if (attribute == null || attribute.length == 0) {
            return null;
        }
        return Encoders.writeValueAsStringSafe(attribute);
    }

    @Override
    public String[] convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        try {
            return Encoders.OBJECT_MAPPER.readValue(dbData, String[].class);
        } catch (JsonProcessingException ex) {
            throw new IllegalArgumentException("Invalid String[] value: " + dbData);
        }
    }

}
