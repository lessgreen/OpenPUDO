package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.UserService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.MultipartUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import less.green.openpudo.rest.dto.pudo.PudoSummaryListResponse;
import less.green.openpudo.rest.dto.scalar.UUIDResponse;
import less.green.openpudo.rest.dto.user.*;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.util.List;
import java.util.UUID;

import static less.green.openpudo.common.MultipartUtils.ALLOWED_IMAGE_MIME_TYPES;
import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Path("/user")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class UserResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    UserService userService;

    @GET
    @Path("/{userId}/profile")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for specific user")
    public UserProfileResponse getUserProfileByUserId(@PathParam(value = "userId") Long userId) {
        UserProfile ret = userService.getUserProfileByUserId(userId);
        return new UserProfileResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me/profile")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for current user")
    public UserProfileResponse getCurrentUserProfile() {
        UserProfile ret = userService.getCurrentUserProfile();
        return new UserProfileResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @PUT
    @Path("/me/profile")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update profile for current user")
    public UserProfileResponse updateCurrentUserProfile(UserProfile req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        UserProfile ret = userService.updateCurrentUserProfile(req);
        return new UserProfileResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @PUT
    @Path("/me/profile-pic")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update profile picture for current user")
    public UUIDResponse updateCurrentUserProfilePic(MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = MultipartUtils.readUploadedFile(req);
        } catch (IOException ex) {
            log.error(ex.getMessage());
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "multipart name"));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "mimeType"));
        }

        UUID ret = userService.updateCurrentUserProfilePic(uploadedFile.getValue0(), uploadedFile.getValue1());
        return new UUIDResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me/preferences")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get preferences for current user")
    public UserPreferencesResponse getCurrentUserPreferences() {
        UserPreferences ret = userService.getCurrentUserPreferences();
        return new UserPreferencesResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @PUT
    @Path("/me/preferences")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update preferences for current user")
    public UserPreferencesResponse updateCurrentUserPreferences(UserPreferences req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (req.getShowPhoneNumber() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "showPhoneNumber"));
        }

        UserPreferences ret = userService.updateCurrentUserPreferences(req);
        return new UserPreferencesResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/me/device-tokens")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Store or refresh device token for current user")
    public BaseResponse upsertDeviceToken(DeviceToken req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (isEmpty(req.getDeviceToken())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "deviceToken"));
        }

        userService.upsertDeviceToken(req);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @GET
    @Path("/me/pudos")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get favourite PUDOs for current user")
    public PudoSummaryListResponse getCurrentUserPudos() {
        List<PudoSummary> ret = userService.getCurrentUserPudos();
        return new PudoSummaryListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/me/pudos/{pudoId}")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Add PUDO to current user's favourite PUDOs")
    public PudoSummaryListResponse addPudoToFavourites(@PathParam(value = "pudoId") Long pudoId) {
        List<PudoSummary> ret = userService.addPudoToFavourites(pudoId);
        return new PudoSummaryListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @DELETE
    @Path("/me/pudos/{pudoId}")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Remove PUDO from current user's favourite PUDOs")
    public PudoSummaryListResponse removePudoFromFavourites(@PathParam(value = "pudoId") Long pudoId) {
        List<PudoSummary> ret = userService.removePudoFromFavourites(pudoId);
        return new PudoSummaryListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
