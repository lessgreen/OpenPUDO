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
import less.green.openpudo.rest.dto.scalar.StringResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
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
            description = "The client calls this API to request an OTP to validate its credentials.\n\n"
                          + "The phone number must start with international prefix, and will be internally normalized in E.164 standard format.\n\n"
                          + "This is a public API and can be invoked without a valid access token.")
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
        PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPhoneNumber(), false);
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
            description = "The client calls this API to confirm the OTP and validate its credentials.\n\n"
                          + "This is a public API and can be invoked without a valid access token.")
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
        PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPhoneNumber(), false);
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
        } else if (req.getUser() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "user"));
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
        } else if (req.getAddressMarker() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "addressMarker"));
        } else if (req.getAddressMarker().getAddress() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "address"));
        } else if (req.getAddressMarker().getAddress().getLabel() == null || req.getAddressMarker().getAddress().getStreet() == null
                   || req.getAddressMarker().getAddress().getCity() == null || req.getAddressMarker().getAddress().getProvince() == null
                   || req.getAddressMarker().getAddress().getCountry() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.address.not_precise"));
        } else if (isEmpty(req.getAddressMarker().getSignature())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "signature"));
        } else if (!cryptoService.isValidSignature(req.getAddressMarker().getAddress(), req.getAddressMarker().getSignature())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "signature"));
        } else if (req.getRewardPolicy() == null || req.getRewardPolicy().isEmpty()) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "rewardPolicy"));
        } else if (context.getPrivateClaims() == null || context.getPrivateClaims().getPhoneNumber() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }
        // normalizing phone number
        if (!isEmpty(req.getPudo().getPublicPhoneNumber())) {
            PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPudo().getPublicPhoneNumber(), true);
            if (!pns.isValid()) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "publicPhoneNumber"));
            }
            req.getPudo().setPublicPhoneNumber(pns.getNormalizedPhoneNumber());
        }

        AccessTokenData ret = authService.registerPudo(req);
        return new LoginConfirmResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/renew")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Renew access token before expiration")
    public LoginConfirmResponse renew() {
        AccessTokenData ret = authService.renew();
        return new LoginConfirmResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/support")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Send a support request")
    public BaseResponse supportRequest(SupportRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (isEmpty(req.getMessage())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "message"));
        }
        authService.supportRequest(req);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @DELETE
    @Path("/account")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Delete user account permanently")
    public StringResponse deleteCurrentAccount() {
        String ret = authService.deleteCurrentAccount();
        return new StringResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
