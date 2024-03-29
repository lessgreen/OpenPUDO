package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.PudoService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.PhoneNumberUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.annotation.ProtectedAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.pack.PackageSummary;
import less.green.openpudo.rest.dto.pack.PackageSummaryListResponse;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoResponse;
import less.green.openpudo.rest.dto.pudo.UpdatePudoRequest;
import less.green.openpudo.rest.dto.pudo.reward.RewardOption;
import less.green.openpudo.rest.dto.pudo.reward.RewardOptionListResponse;
import less.green.openpudo.rest.dto.scalar.UUIDResponse;
import less.green.openpudo.rest.dto.user.UserSummary;
import less.green.openpudo.rest.dto.user.UserSummaryListResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

import static less.green.openpudo.common.MultipartUtils.*;
import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Path("/pudo")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class PudoResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    CryptoService cryptoService;

    @Inject
    PudoService pudoService;

    @GET
    @Path("/{pudoId}")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for specific PUDO")
    public PudoResponse getPudo(@PathParam(value = "pudoId") Long pudoId) {
        Pudo ret = pudoService.getPudo(pudoId);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for current PUDO")
    public PudoResponse getCurrentPudo() {
        Pudo ret = pudoService.getCurrentPudo();
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/me")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update profile for current PUDO",
            description = "You can update base PUDO information and/or PUDO address. At least one of those fields must be present in the request.")
    public PudoResponse updateCurrentPudo(UpdatePudoRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (req.getPudo() == null && req.getAddressMarker() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field_coalesce", "pudo, addressMarker"));
        }
        if (req.getPudo() != null && isEmpty(req.getPudo().getBusinessName())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "businessName"));
        }
        if (req.getAddressMarker() != null) {
            if (req.getAddressMarker().getAddress() == null) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "address"));
            } else if (req.getAddressMarker().getAddress().getLabel() == null || req.getAddressMarker().getAddress().getStreet() == null
                       || req.getAddressMarker().getAddress().getCity() == null || req.getAddressMarker().getAddress().getProvince() == null
                       || req.getAddressMarker().getAddress().getCountry() == null) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.address.not_precise"));
            } else if (isEmpty(req.getAddressMarker().getSignature())) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "signature"));
            }
        }
        // normalizing phone number
        if (req.getPudo() != null && !isEmpty(req.getPudo().getPublicPhoneNumber())) {
            PhoneNumberUtils.PhoneNumberSummary pns = PhoneNumberUtils.normalizePhoneNumber(req.getPudo().getPublicPhoneNumber(), true);
            if (!pns.isValid()) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "publicPhoneNumber"));
            }
            req.getPudo().setPublicPhoneNumber(pns.getNormalizedPhoneNumber());
        }
        Pudo ret = pudoService.updateCurrentPudo(req);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @PUT
    @Path("/me/picture")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update picture for current PUDO")
    public UUIDResponse updateCurrentPudoPicture(MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = readUploadedFile(req);
        } catch (IOException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", PART_NAME));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", CONTENT_TYPE));
        }

        UUID ret = pudoService.updateCurrentPudoPicture(uploadedFile.getValue1());
        return new UUIDResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/reward-schema")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get PUDO rewards definition schema")
    public RewardOptionListResponse getRewardSchema() {
        List<RewardOption> ret = pudoService.getRewardSchema();
        return new RewardOptionListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me/reward-policy")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get reward policy for current PUDO")
    public RewardOptionListResponse getCurrentPudoRewardPolicy() {
        List<RewardOption> ret = pudoService.getCurrentPudoRewardPolicy();
        return new RewardOptionListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/me/reward-policy")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update reward policy for current PUDO")
    public RewardOptionListResponse updateCurrentPudoRewardPolicy(List<RewardOption> rewardPolicy) {
        List<RewardOption> ret = pudoService.updateCurrentPudoRewardPolicy(rewardPolicy);
        return new RewardOptionListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me/packages")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get package list for current PUDO, with optional query parameters",
            description = "If called without parameters, this API return the summary of all packages in \"open\" state for the current PUDO.\n\n"
                          + "Parameters can be used to perform an historical search, and pagination will be used only in this mode.")
    public PackageSummaryListResponse getCurrentPudoPackages(
            @Parameter(description = "Historical search") @DefaultValue("false") @QueryParam("history") boolean history,
            @Parameter(description = "Pagination limit, used only in historical search") @DefaultValue("20") @QueryParam("limit") int limit,
            @Parameter(description = "Pagination offset, used only in historical search") @DefaultValue("0") @QueryParam("offset") int offset) {
        // sanitize input
        if (limit < 1) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "limit"));
        }
        if (offset < 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "offset"));
        }

        List<PackageSummary> ret = pudoService.getCurrentPudoPackages(history, limit, offset);
        return new PackageSummaryListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me/users")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get of users subscribed to current PUDO")
    public UserSummaryListResponse getCurrentPudoUsers() {
        List<UserSummary> ret = pudoService.getCurrentPudoUsers();
        return new UserSummaryListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
