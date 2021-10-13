package less.green.openpudo.rest.config.exception;


import lombok.Getter;

public class ApiException extends RuntimeException {

    @Getter
    private final int returnCode;

    public ApiException(int returnCode, String message) {
        super(message);
        this.returnCode = returnCode;
    }

}
