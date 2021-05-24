package less.green.openpudo.persistence.dao.usertype;

import lombok.Getter;

public enum RoleType {
    OWNER("owner"),
    CUSTOMER("customer");

    @Getter
    private final String val;

    RoleType(String val) {
        this.val = val;
    }

}
