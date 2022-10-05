package less.green.openpudo.business.model.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class DynamicLinkRouteConverter implements AttributeConverter<DynamicLinkRoute, String> {

    @Override
    public String convertToDatabaseColumn(DynamicLinkRoute attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getValue();
    }

    @Override
    public DynamicLinkRoute convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (var i : DynamicLinkRoute.values()) {
            if (i.getValue().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid DynamicLinkRoute: " + dbData);
    }

}
