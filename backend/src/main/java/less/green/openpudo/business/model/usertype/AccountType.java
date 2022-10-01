package less.green.openpudo.business.model.usertype;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

@Schema(enumeration = {"pudo", "customer"})
public enum AccountType {
    @JsonProperty("pudo")
    PUDO("pudo"),
    @JsonProperty("customer")
    CUSTOMER("customer");

    @Getter
    private final String value;

    AccountType(String value) {
        this.value = value;
    }

}
