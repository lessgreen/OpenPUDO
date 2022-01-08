package less.green.openpudo.persistence.model.usertype;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Converter
public class AccountTypeConverter implements AttributeConverter<AccountType, String> {

    @Override
    public String convertToDatabaseColumn(AccountType attribute) {
        if (attribute == null) {
            return null;
        }
        return attribute.getValue();
    }

    @Override
    public AccountType convertToEntityAttribute(String dbData) {
        if (isEmpty(dbData)) {
            return null;
        }
        for (AccountType i : AccountType.values()) {
            if (i.getValue().equals(dbData)) {
                return i;
            }
        }
        throw new IllegalArgumentException("Invalid AccountType: " + dbData);
    }

}
