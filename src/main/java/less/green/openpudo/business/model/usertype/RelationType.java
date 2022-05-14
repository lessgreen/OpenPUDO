package less.green.openpudo.business.model.usertype;

import lombok.Getter;

public enum RelationType {
    OWNER("owner"),
    CUSTOMER("customer");

    @Getter
    private final String value;

    RelationType(String value) {
        this.value = value;
    }

}
