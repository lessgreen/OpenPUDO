package less.green.openpudo.rest.config.exception;

import lombok.Data;

@Data
public class ApiException extends RuntimeException {

    private final int returnCode;
    private final String message;

}
