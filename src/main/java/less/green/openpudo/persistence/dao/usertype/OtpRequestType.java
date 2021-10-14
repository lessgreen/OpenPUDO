package less.green.openpudo.persistence.dao.usertype;

import lombok.Getter;

public enum OtpRequestType {
    RESET_PASSWORD("reset_password");

    @Getter
    private final String value;

    OtpRequestType(String value) {
        this.value = value;
    }

}
