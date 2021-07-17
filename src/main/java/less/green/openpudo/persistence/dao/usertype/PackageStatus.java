package less.green.openpudo.persistence.dao.usertype;

import lombok.Getter;

public enum PackageStatus {
    DELIVERED("delivered"),
    NOTIFIED("notified"),
    COLLECTED("collected"),
    ACCEPTED("accepted"),
    EXPIRED("expired"),
    RETURNED("returned");

    @Getter
    private final String value;

    PackageStatus(String value) {
        this.value = value;
    }

}
