package less.green.openpudo.common;

public class ApiReturnCodes {

    public static final int OK = 0;
    public static final int BAD_REQUEST = 400;
    public static final int INVALID_JWT_TOKEN = 401;
    public static final int EXPIRED_JWT_TOKEN = 401;
    public static final int INVALID_OTP = 401;
    public static final int FORBIDDEN = 403;
    public static final int RESOURCE_NOT_FOUND = 404;
    public static final int INTERNAL_SERVER_ERROR = 500;
    public static final int SERVICE_UNAVAILABLE = 503;

    private ApiReturnCodes() {
    }

}
