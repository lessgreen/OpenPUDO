package less.green.openpudo.persistence.dao.usertype;

import lombok.Getter;

public enum PackageStatus {
    DELIVERED("delivered"),
    COLLECTED("collected"),
    CONFIRMED("confirmed"),
    RETURNED("returned");

    @Getter
    private final String value;

    PackageStatus(String value) {
        this.value = value;
    }

}
