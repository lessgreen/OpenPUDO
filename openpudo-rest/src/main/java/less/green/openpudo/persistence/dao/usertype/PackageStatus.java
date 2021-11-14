package less.green.openpudo.persistence.dao.usertype;

import lombok.Getter;

public enum PackageStatus {
    DELIVERED("delivered"),
    NOTIFY_SENT("notify_sent"),
    NOTIFIED("notified"),
    COLLECTED("collected"),
    ACCEPTED("accepted"),
    EXPIRED("expired");

    @Getter
    private final String value;

    PackageStatus(String value) {
        this.value = value;
    }

}
