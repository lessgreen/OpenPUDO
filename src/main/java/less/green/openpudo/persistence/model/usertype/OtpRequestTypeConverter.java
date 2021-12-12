package less.green.openpudo.persistence.model.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class OtpRequestTypeConverter implements AttributeConverter<OtpRequestType, String> {

    @Override
    public String convertToDatabaseColumn(OtpRequestType attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getValue();
    }

    @Override
    public OtpRequestType convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (OtpRequestType i : OtpRequestType.values()) {
            if (i.getValue().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid OtpRequestType: " + dbData);
    }

}
