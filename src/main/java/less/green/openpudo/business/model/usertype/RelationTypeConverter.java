package less.green.openpudo.persistence.model.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class RelationTypeConverter implements AttributeConverter<RelationType, String> {

    @Override
    public String convertToDatabaseColumn(RelationType attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getValue();
    }

    @Override
    public RelationType convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (RelationType i : RelationType.values()) {
            if (i.getValue().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid RelationType: " + dbData);
    }

}
