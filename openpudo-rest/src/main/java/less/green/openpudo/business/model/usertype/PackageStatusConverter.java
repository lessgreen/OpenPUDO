package less.green.openpudo.business.model.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class PackageStatusConverter implements AttributeConverter<PackageStatus, String> {

    @Override
    public String convertToDatabaseColumn(PackageStatus attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getValue();
    }

    @Override
    public PackageStatus convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (PackageStatus i : PackageStatus.values()) {
            if (i.getValue().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid PackageStatus: " + dbData);
    }

}
