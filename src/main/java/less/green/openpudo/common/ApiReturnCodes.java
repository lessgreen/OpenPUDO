package less.green.openpudo.common;

public class ApiReturnCodes {

    public static final int OK = 0;
    public static final int INVALID_REQUEST = 1;
    public static final int INVALID_CREDENTIALS = 2;
    public static final int INVALID_JWT_TOKEN = 3;
    public static final int EXPIRED_JWT_TOKEN = 4;

    private ApiReturnCodes() {
    }

}
