package less.green.openpudo.business.model.usertype;

import less.green.openpudo.common.Encoders;

import javax.persistence.AttributeConverter;
import java.util.Map;

import static less.green.openpudo.common.StringUtils.isEmpty;

public class JsonConverter implements AttributeConverter<Map<String, Object>, String> {

    @Override
    public String convertToDatabaseColumn(Map<String, Object> attribute) {
        if (attribute == null || attribute.isEmpty()) {
            return null;
        }
        return Encoders.writeJson(attribute);
    }

    @Override
    public Map<String, Object> convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        return Encoders.readJsonAsMap(dbData);
    }

}
