package less.green.openpudo.business.model.usertype;

import lombok.Getter;

public enum AccountType {
    PUDO("pudo"),
    CUSTOMER("customer");

    @Getter
    private final String value;

    AccountType(String value) {
        this.value = value;
    }

}
