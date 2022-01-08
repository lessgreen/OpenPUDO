package less.green.openpudo.persistence.model.usertype;

import lombok.Getter;

public enum OtpRequestType {
    LOGIN("login");

    @Getter
    private final String value;

    OtpRequestType(String value) {
        this.value = value;
    }

}
