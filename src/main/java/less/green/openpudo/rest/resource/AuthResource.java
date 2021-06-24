package less.green.openpudo.rest.resource;

import com.fasterxml.jackson.core.JsonProcessingException;
import java.util.regex.Pattern;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.InternalServerErrorException;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import static less.green.openpudo.common.FormatUtils.safeNormalizePhoneNumber;
import static less.green.openpudo.common.StringUtils.isEmpty;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.common.dto.AccountSecret;
import less.green.openpudo.common.dto.JwtPayload;
import less.green.openpudo.persistence.model.TbAccount;
import less.green.openpudo.persistence.service.AccountService;
import less.green.openpudo.persistence.service.UserService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.auth.AccessTokenData;
import less.green.openpudo.rest.dto.auth.LoginRequest;
import less.green.openpudo.rest.dto.auth.LoginResponse;
import less.green.openpudo.rest.dto.auth.RegisterRequest;
import less.green.openpudo.rest.dto.auth.RenewRequest;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

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
    // (?!.*[_.]{2}) -> no consecutives dot or underscores
    // [a-zA-Z0-9._]+ -> allowed chars: numbers and letters in mixed case, dot and underscore
    // (?<![_.]) -> no dot or underscore at the end
    private static final String USERNAME_REGEX = "^(?=.{6,20}$)(?![_.])(?!.*[_.]{2})[a-zA-Z0-9._]+(?<![_.])$";
    private static final Pattern USERNAME_PATTERN = Pattern.compile(USERNAME_REGEX);
    // (?=.{8,}) -> at least 8 char
    // (?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]) -> at least one lowercase latter, one uppercase, one number
    private static final String PASSWORD_REGEX = "^(?=.{8,}$)(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).+$";
    private static final Pattern PASSWOD_PATTERN = Pattern.compile(PASSWORD_REGEX);
    private static final String EMAIL_REGEX = "(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    private static final Pattern EMAIL_PATTERN = Pattern.compile(EMAIL_REGEX);
    private static final String PHONENUMBER_REGEX = "^\\+?[0-9 ]{8,}$";
    private static final Pattern PHONENUMBER_PATTERN = Pattern.compile(PHONENUMBER_REGEX);

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
    @Operation(summary = "Register new user",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
            + "Fields 'email' and 'phoneNumber' are technically optional, but you must provide at least one of them.\n\n"
            + "If field 'pudo' is present, then the user is registering himself as a PUDO.")
    public BaseResponse register(RegisterRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getUsername()) && isEmpty(req.getEmail()) && isEmpty(req.getPhoneNumber())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field_coalesce", "email, phoneNumber"));
        } else if (isEmpty(req.getPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "password"));
        }
        // user fields
        if (req.getUser() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "user"));
        } else if (isEmpty(req.getUser().getFirstName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "user.firstName"));
        } else if (isEmpty(req.getUser().getLastName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "user.lastName"));
        }
        // pudo fields
        if (req.getPudo() != null && isEmpty(req.getPudo().getBusinessName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "pudo.businessName"));
        }

        // more sanitizing
        String username = sanitizeString(req.getUsername());
        if (username != null && !USERNAME_PATTERN.matcher(username).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "username"));
        }
        req.setUsername(username);

        String email = sanitizeString(req.getEmail());
        if (email != null && !EMAIL_PATTERN.matcher(email).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "email"));
        }
        req.setEmail(email);

        String phoneNumber = sanitizeString(req.getPhoneNumber());
        if (phoneNumber != null) {
            String npn = safeNormalizePhoneNumber(phoneNumber);
            if (npn == null) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "phoneNumber"));
            }
            phoneNumber = npn;
        }
        req.setPhoneNumber(phoneNumber);

        String password = req.getPassword();
        if (!PASSWOD_PATTERN.matcher(password).matches()) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.auth.password_too_easy"));
        }

        if (req.getPudo() != null && !isEmpty(req.getPudo().getPhoneNumber())) {
            String npn = safeNormalizePhoneNumber(req.getPudo().getPhoneNumber());
            if (npn == null) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "pudo.phoneNumber"));
            }
            req.getPudo().setPhoneNumber(npn);
        }

        // cheack if already registered
        if (accountService.findAccountByLogin(username) != null || accountService.findAccountByLogin(email) != null || accountService.findAccountByLogin(phoneNumber) != null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.auth.credentials_already_used"));
        }

        // all checks passed, registering use
        Long userId = userService.register(req);
        log.info("[{}] Registered user, userId: {}", context.getExecutionId(), userId);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/login")
    @Operation(summary = "Authenticate user and generate JWT access token",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
            + "Any failed attemp will enforce a response delay to discourage bruteforcing.")
    public LoginResponse login(LoginRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getLogin())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "login"));
        } else if (isEmpty(req.getPassword())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "password"));
        }

        // normalizing login
        String login = req.getLogin().trim();
        // if user is logging in by something like a phone numer, try to normalize
        if (PHONENUMBER_PATTERN.matcher(login).matches()) {
            String npn = safeNormalizePhoneNumber(login);
            login = npn != null ? npn : login;
        }

        // search user in database
        TbAccount account = accountService.findAccountByLogin(login);
        if (account == null) {
            log.error("[{}] Failed login attempt for login '{}': account does not exists", context.getExecutionId(), login);
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage("error.auth.invalid_credentials"));
        }
        // verify credentials
        AccountSecret secret = new AccountSecret(account.getSalt(), account.getPassword(), account.getHashSpecs());
        if (!cryptoService.verifyPasswordHash(secret, req.getPassword())) {
            log.error("[{}] Failed login attempt for userId {}: wrong password", context.getExecutionId(), account.getUserId());
            delayFailureResponse();
            throw new ApiException(ApiReturnCodes.INVALID_CREDENTIALS, localizationService.getMessage("error.auth.invalid_credentials"));
        }

        // creating access token
        AccessTokenData resp = generateLoginResponsePayload(account.getUserId());
        log.info("[{}] Login successful for userId: {}", context.getExecutionId(), account.getUserId());
        return new LoginResponse(context.getExecutionId(), 0, resp);
    }

    @POST
    @Path("/renew")
    @Operation(summary = "Renew JWT access token", description = "This is a public API, and will renew a valid access token, even if expired")
    public LoginResponse renew(RenewRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getAccessToken())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "accessToken"));
        }

        // checking signature
        String accessToken = req.getAccessToken();
        if (jwtService.verifyAccessTokenSignature(accessToken) == false) {
            log.error("[{}] Failed renew attempt: invalid token signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage("error.auth.invalid_access_token"));
        }
        // if access token is valid, checking for expiration
        JwtPayload payload;
        try {
            payload = jwtService.decodePayload(accessToken.split("\\.", -1)[1]);
        } catch (JsonProcessingException ex) {
            // we have a valid signature for an unparsable payload, this should NEVER happen, triggering an internal server error
            log.error("[{}] Authorization failed: invalid token payload with valid signature", context.getExecutionId());
            throw new InternalServerErrorException();
        }

        AccessTokenData resp = generateLoginResponsePayload(payload.getSub());
        return new LoginResponse(context.getExecutionId(), 0, resp);
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
