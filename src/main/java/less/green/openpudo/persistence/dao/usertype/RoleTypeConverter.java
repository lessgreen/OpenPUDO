package less.green.openpudo.persistence.dao.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;
import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class RoleTypeConverter implements AttributeConverter<RoleType, String> {

    @Override
    public String convertToDatabaseColumn(RoleType attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getVal();
    }

    @Override
    public RoleType convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (RoleType i : RoleType.values()) {
            if (i.getVal().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid RoleType: " + dbData);
    }

}
