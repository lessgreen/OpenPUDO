package less.green.openpudo.rest.resource;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.PhoneNumberUtils;
import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.persistence.service.AuthService;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.auth.LoginConfirmRequest;
import less.green.openpudo.rest.dto.auth.LoginConfirmResponse;
import less.green.openpudo.rest.dto.auth.LoginSendRequest;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Path("/auth")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class AuthResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    AuthService authService;

    @POST
    @Path("/login/send")
    @PublicAPI
    @Operation(summary = "First phase of password-less authentication or registration",
            description = "The client calls this API to request an OTP to validate its credentials.\n\n" +
                    "This is a public API and can be invoked without a valid access token.")
    public BaseResponse loginSend(LoginSendRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (isEmpty(req.getPhoneNumber())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "phoneNumber"));
        } else if (!req.getPhoneNumber().trim().startsWith("+")) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "phoneNumber"));
        }
        // normalizing phone number
        PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPhoneNumber());
        if (!pns.isValid() || !pns.isMobile()) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "phoneNumber"));
        }

        authService.loginSend(pns.getNormalizedPhoneNumber());
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/login/confirm")
    @PublicAPI
    @Operation(summary = "Second phase of password-less authentication or registration",
            description = "The client calls this API to confirm the OTP and validate its credentials.\n\n" +
                    "This is a public API and can be invoked without a valid access token.")
    public LoginConfirmResponse loginConfirm(LoginConfirmRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (isEmpty(req.getPhoneNumber())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "phoneNumber"));
        } else if (isEmpty(req.getOtp())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "otp"));
        } else if (!req.getPhoneNumber().trim().startsWith("+")) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "phoneNumber"));
        }
        // normalizing phone number
        PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPhoneNumber());
        if (!pns.isValid() || !pns.isMobile()) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "phoneNumber"));
        }

        AccessTokenData ret = authService.loginConfirm(pns.getNormalizedPhoneNumber(), req.getOtp());
        return new LoginConfirmResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
