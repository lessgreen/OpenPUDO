package less.green.openpudo.rest.resource;

import com.fasterxml.jackson.core.JsonProcessingException;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.common.dto.JwtPayload;
import less.green.openpudo.persistence.dao.usertype.OtpRequestType;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.persistence.model.TbOtpRequest;
import less.green.openpudo.persistence.service.AccountService;
import less.green.openpudo.persistence.service.UserService;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.auth.*;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.regex.Pattern;

import static less.green.openpudo.common.FormatUtils.normalizeLoginSafe;
import static less.green.openpudo.common.FormatUtils.normalizePhoneNumberSafe;
import static less.green.openpudo.common.StringUtils.isEmpty;
import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class AuthResource {

    private static final int LOGIN_ERROR_DELAY_MS = 1_000;
    // validation regex uses zero-width lookahead:
    // (?=.{6,20}$) -> 6 to 20 chars
    // (?![_.]) -> no dot or underscore at the beginning
    // (?!.*[_.]{2}) -> no consecutive dot or underscores
    // [a-zA-Z0-9._]+ -> allowed chars: numbers and letters in mixed case, dot and underscore
    // (?<![_.]) -> no dot or underscore at the end
    private static final String USERNAME_REGEX = "^(?=.{6,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$";
    private static final Pattern USERNAME_PATTERN = Pattern.compile(USERNAME_REGEX);
    // (?=.{8,}) -> at least 8 char
    // (?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]) -> at least one lowercase latter, one uppercase, one number
    private static final String PASSWORD_REGEX = "^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).+$";
    private static final Pattern PASSWOD_PATTERN = Pattern.compile(PASSWORD_REGEX);
    private static final String EMAIL_REGEX = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)])";
    private static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_REGEX);

    @Inject
    ExecutionContext context;

    @Inject
    CryptoService cryptoService;
    @Inject
    JwtService jwtService;
    @Inject
    LocalizationService localizationService;

    @Inject
    AccountService accountService;
    @Inject
    UserService userService;

    @POST
    @Path("/register")
    @PublicAPI
    @Operation(summary = "Register new user",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
                    + "Fields 'email' and 'phoneNumber' are technically optional, but you must provide at least one of them.\n\n"
                    + "If field 'pudo' is present, then the user is registering himself as a PUDO.")
    public BaseResponse register(RegisterRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getEmail()) && isEmpty(req.getPhoneNumber())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field_coalesce", "email, phoneNumber"));
        } else if (isEmpty(req.getPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "password"));
        }
        // user fields
        if (req.getUser() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "user"));
        } else if (isEmpty(req.getUser().getFirstName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "user.firstName"));
        } else if (isEmpty(req.getUser().getLastName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "user.lastName"));
        }
        // pudo fields
        if (req.getPudo() != null && isEmpty(req.getPudo().getBusinessName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "pudo.businessName"));
        }

        // more sanitizing
        String username = sanitizeString(req.getUsername());
        if (username != null && !USERNAME_PATTERN.matcher(username).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "username"));
        }
        req.setUsername(username);

        String email = sanitizeString(req.getEmail());
        if (email != null && !EMAIL_PATTERN.matcher(email).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "email"));
        }
        req.setEmail(email);

        String phoneNumber = sanitizeString(req.getPhoneNumber());
        if (phoneNumber != null) {
            String npn = normalizePhoneNumberSafe(phoneNumber, language);
            if (npn == null) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "phoneNumber"));
            }
            phoneNumber = npn;
        }
        req.setPhoneNumber(phoneNumber);

        String password = req.getPassword();
        if (!PASSWOD_PATTERN.matcher(password).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.auth.password_too_easy"));
        }

        if (req.getPudo() != null) {
            String pudoPhoneNumber = sanitizeString(req.getPudo().getPhoneNumber());
            if (pudoPhoneNumber != null) {
                String npn = normalizePhoneNumberSafe(pudoPhoneNumber, language);
                if (npn == null) {
                    throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "pudo.phoneNumber"));
                }
                pudoPhoneNumber = npn;
            }
            req.getPudo().setPhoneNumber(pudoPhoneNumber);
        }

        // check if already registered
        if (accountService.getAccountByLogin(username) != null || accountService.getAccountByLogin(email) != null || accountService.getAccountByLogin(phoneNumber) != null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.auth.credentials_already_used"));
        }

        // all checks passed, registering use
        Long userId = userService.register(req);
        log.info("[{}] Registered user: {}", context.getExecutionId(), userId);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/login")
    @PublicAPI
    @Operation(summary = "Authenticate user and generate JWT access token",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
                    + "Any failed attempt will enforce a response delay to discourage bruteforce.")
    public LoginResponse login(LoginRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getLogin())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "login"));
        } else if (isEmpty(req.getPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "password"));
        }

        // normalizing login
        String login = normalizeLoginSafe(req.getLogin(), language);

        // search user in database
        TbAccount account = accountService.getAccountByLogin(login);
        if (account == null) {
            log.error("[{}] Failed login attempt for login '{}': account does not exists", context.getExecutionId(), login);
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }
        // verify credentials
        AccountSecret secret = new AccountSecret(account.getSalt(), account.getPassword(), account.getHashSpecs());
        if (!cryptoService.verifyPasswordHash(secret, req.getPassword())) {
            log.error("[{}] Failed login attempt for userId {}: wrong password", context.getExecutionId(), account.getUserId());
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }

        // creating access token
        AccessTokenData resp = generateLoginResponsePayload(account.getUserId());
        log.info("[{}] Login successful for user: {}", context.getExecutionId(), account.getUserId());
        return new LoginResponse(context.getExecutionId(), 0, resp);
    }

    @POST
    @Path("/renew")
    @PublicAPI
    @Operation(summary = "Renew JWT access token", description = "This is a public API and can be invoked without a valid access token.\n\n" +
            "It will renew a valid access token, even if expired")
    public LoginResponse renew(RenewRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getAccessToken())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "accessToken"));
        }

        // checking signature
        String accessToken = req.getAccessToken();
        if (!jwtService.verifyAccessTokenSignature(accessToken)) {
            log.error("[{}] Failed renew attempt: invalid token signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(language, "error.auth.invalid_access_token"));
        }
        // if access token is valid, checking for expiration
        JwtPayload payload;
        try {
            payload = jwtService.decodePayload(accessToken.split("\\.", -1)[1]);
        } catch (JsonProcessingException ex) {
            // we have a valid signature for a not parsable payload, this should NEVER happen, triggering an internal server error
            log.error("[{}] Authorization failed: invalid token payload with valid signature", context.getExecutionId());
            throw new InternalServerErrorException();
        }

        AccessTokenData resp = generateLoginResponsePayload(payload.getSub());
        return new LoginResponse(context.getExecutionId(), 0, resp);
    }

    @POST
    @Path("/change-password")
    @Operation(summary = "Change password", description = "Change user's password. Old password must be provided and will be checked for security reasons.")
    public BaseResponse changePassword(ChangePasswordRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getOldPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "oldPassword"));
        } else if (isEmpty(req.getNewPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "newPassword"));
        }

        // search user in database
        TbAccount account = accountService.getAccountByUserId(context.getUserId());
        // verify credentials
        AccountSecret secret = new AccountSecret(account.getSalt(), account.getPassword(), account.getHashSpecs());
        if (!cryptoService.verifyPasswordHash(secret, req.getOldPassword())) {
            log.error("[{}] Failed change password attempt for userId {}: wrong password", context.getExecutionId(), account.getUserId());
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }

        // all checks passed, changing password
        accountService.changePassword(context.getUserId(), req.getNewPassword());
        log.info("[{}] Changed password for user: {}", context.getExecutionId(), context.getUserId());
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/reset-password")
    @PublicAPI
    @Operation(summary = "Reset password", description = "This is a public API and can be invoked without a valid access token.\n\n" +
            "It will hide details for error related to user's account for security reasons.\n\n" +
            "This is the first API to call when an unauthenticated user wants to reset his password. Backend will generate a secure OTP and send it to the user via email or SMS.\n\n" +
            "A subsequent call to another API must be done to confirm user's identity.")
    public BaseResponse resetPassword(ResetPasswordRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getLogin())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "login"));
        }

        // normalizing login
        String login = normalizeLoginSafe(req.getLogin(), language);

        // search user in database
        TbAccount account = accountService.getAccountByLogin(login);
        if (account == null) {
            log.error("[{}] Failed reset password attempt for login '{}': account does not exists", context.getExecutionId(), login);
            return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
        }

        accountService.resetPassword(account.getUserId(), language);
        log.info("[{}] Reset password request for user: {}", context.getExecutionId(), account.getUserId());
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/confirm-reset-password")
    @PublicAPI
    @Operation(summary = "Confirm reset password", description = "This is a public API and can be invoked without a valid access token.\n\n" +
            "It will hide details for error related to user's account for security reasons.\n\n" +
            "This is the second API to call when an unauthenticated user wants to reset his password. Backend will check OTP to confirm user's identity.")
    public BaseResponse confirmResetPassword(ConfirmResetPasswordRequest req, @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_request"));
        } else if (isEmpty(req.getLogin())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "login"));
        } else if (isEmpty(req.getOtp())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "otp"));
        } else if (isEmpty(req.getLogin())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "newPassword"));
        }

        // normalizing login
        String login = normalizeLoginSafe(req.getLogin(), language);

        // search user in database
        TbAccount account = accountService.getAccountByLogin(login);
        if (account == null) {
            log.error("[{}] Failed confirm reset password attempt for login '{}': account does not exists", context.getExecutionId(), login);
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }

        // search existing request in database
        TbOtpRequest otpRequest = accountService.getOtpRequestByUserIdAndRequestType(account.getUserId(), OtpRequestType.RESET_PASSWORD);
        if (otpRequest == null) {
            log.error("[{}] Failed confirm reset password attempt for user '{}': request does not exists", context.getExecutionId(), account.getUserId());
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }

        // checking OTP and password
        if (!otpRequest.getOtp().equals(req.getOtp())) {
            log.error("[{}] Failed confirm reset password attempt for user '{}': wrong OTP", context.getExecutionId(), account.getUserId());
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage(language, "error.auth.invalid_credentials"));
        }
        if (!PASSWOD_PATTERN.matcher(req.getNewPassword()).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.auth.password_too_easy"));
        }

        accountService.confirmResetPassword(account.getUserId(), req.getNewPassword(), otpRequest.getRequestId());
        log.info("[{}] Reset password confirmed for user: {}", context.getExecutionId(), account.getUserId());
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    private AccessTokenData generateLoginResponsePayload(Long userId) {
        JwtPayload jwtPayload = jwtService.generatePayload(userId);
        String accessToken = jwtService.generateAccessToken(jwtPayload);
        return new AccessTokenData(accessToken, jwtPayload.getIat(), jwtPayload.getExp());
    }

    private void delayFailureResponse() {
        try {
            Thread.sleep(LOGIN_ERROR_DELAY_MS);
        } catch (InterruptedException ex) {
            Thread.currentThread().interrupt();
        }
    }

}
