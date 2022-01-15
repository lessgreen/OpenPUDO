package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.AuthService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.PhoneNumberUtils;
import less.green.openpudo.common.dto.jwt.AccessTokenData;
import less.green.openpudo.rest.config.annotation.ProtectedAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.auth.*;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;

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
    CryptoService cryptoService;

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
        } else if (!PhoneNumberUtils.PHONENUMBER_PATTERN.matcher(req.getPhoneNumber()).matches()) {
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
        } else if (!PhoneNumberUtils.PHONENUMBER_PATTERN.matcher(req.getPhoneNumber()).matches()) {
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

    @POST
    @Path("/register/customer")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Register new user with Customer profile")
    public LoginConfirmResponse registerCustomer(RegisterCustomerRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (req.getUserProfile() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "userProfile"));
        } else if (context.getPrivateClaims() == null || context.getPrivateClaims().getPhoneNumber() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }

        AccessTokenData ret = authService.registerCustomer(req);
        return new LoginConfirmResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/register/pudo")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Register new user with PUDO profile")
    public LoginConfirmResponse registerPudo(RegisterPudoRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (req.getPudo() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "pudo"));
        } else if (isEmpty(req.getPudo().getBusinessName())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "businessName"));
        } else if (req.getSignedAddressMarker() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "signedAddressMarker"));
        } else if (req.getSignedAddressMarker().getAddress() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "address"));
        } else if (isEmpty(req.getSignedAddressMarker().getSignature())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "signature"));
        } else if (context.getPrivateClaims() == null || context.getPrivateClaims().getPhoneNumber() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }
        // normalizing phone number
        if (!isEmpty(req.getPudo().getPublicPhoneNumber())) {
            PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPudo().getPublicPhoneNumber());
            if (!pns.isValid()) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "publicPhoneNumber"));
            }
            req.getPudo().setPublicPhoneNumber(pns.getNormalizedPhoneNumber());
        }
        // verify address integrity
        String signature = cryptoService.signObject(req.getSignedAddressMarker().getAddress());
        if (!signature.equals(req.getSignedAddressMarker().getSignature())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "signature"));
        }

        AccessTokenData ret = authService.registerPudo(req);
        return new LoginConfirmResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
