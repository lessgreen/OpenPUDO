package less.green.openpudo.rest.resource;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.persistence.service.UserService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.file.ExternalFile;
import less.green.openpudo.rest.dto.pudo.PudoListResponse;
import less.green.openpudo.rest.dto.user.User;
import less.green.openpudo.rest.dto.user.UserResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

@RequestScoped
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class UserResource {

    private static final Set<String> ALLOWED_IMAGE_MIME_TYPES = new HashSet<>(Arrays.asList(
            "image/jpeg",
            "image/png",
            "image/gif"
    ));

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    PudoService pudoService;
    @Inject
    UserService userService;

    @Inject
    DtoMapper dtoMapper;

    @GET
    @Path("/{userId}")
    @Operation(summary = "Get public profile for user with provided userId")
    public UserResponse getUserById(@PathParam(value = "userId") Long userId) {
        TbUser user = userService.getUserById(userId);
        return new UserResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserEntityToDto(user));
    }

    @GET
    @Path("/me")
    @Operation(summary = "Get public profile for current user")
    public UserResponse getCurrentUser() {
        return getUserById(context.getUserId());
    }

    @PUT
    @Path("/me")
    @Operation(summary = "Update public profile for current user")
    public UserResponse updateCurrentUser(User req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getFirstName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "firstName"));
        } else if (isEmpty(req.getLastName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lastName"));
        }

        TbUser user = userService.updateUser(context.getUserId(), req);
        return new UserResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserEntityToDto(user));
    }

    @GET
    @Path("/me/pudos")
    @Operation(summary = "Get current user's favourite PUDOs")
    public PudoListResponse getCurrentUserPudos() {
        List<Pair<TbPudo, TbAddress>> pudos = pudoService.getPudoListByCustomer(context.getUserId());
        return new PudoListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoAndAddressEntityListToDtoList(pudos));
    }

    @PUT
    @Path("/me/pudos/{pudoId}")
    @Operation(summary = "Add PUDO to current user's favourite PUDOs")
    public PudoListResponse addPudoToFavourites(@PathParam(value = "pudoId") Long pudoId) {
        // preliminary checks
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (pudoOwner) {
            throw new ApiException(ApiReturnCodes.UNAUTHORIZED, localizationService.getMessage("error.user.pudo_owner"));
        }
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pudoId);
        if (pudo == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.pudo.pudo_not_exists"));
        }
        boolean pudoCustomer = pudoService.isPudoCustomer(context.getUserId(), pudoId);
        if (pudoCustomer) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.pudo.pudo_already_favourite"));
        }

        List<Pair<TbPudo, TbAddress>> pudos = pudoService.addPudoToFavourites(context.getUserId(), pudoId);
        return new PudoListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoAndAddressEntityListToDtoList(pudos));
    }

    @DELETE
    @Path("/me/pudos/{pudoId}")
    @Operation(summary = "Remove PUDO from current user's favourite PUDOs")
    public PudoListResponse removePudoFromFavourites(@PathParam(value = "pudoId") Long pudoId) {
        // preliminary checks
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (pudoOwner) {
            throw new ApiException(ApiReturnCodes.UNAUTHORIZED, localizationService.getMessage("error.user.pudo_owner"));
        }
        boolean pudoCustomer = pudoService.isPudoCustomer(context.getUserId(), pudoId);
        if (!pudoCustomer) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.pudo.pudo_not_favourite"));
        }

        List<Pair<TbPudo, TbAddress>> pudos = pudoService.removePudoFromFavourites(context.getUserId(), pudoId);
        return new PudoListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoAndAddressEntityListToDtoList(pudos));
    }

    @PUT
    @Path("/me/profile-pic")
    @Operation(summary = "Update public profile picture for current user")
    public UserResponse updateCurrentUserProfilePic(ExternalFile req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getMimeType())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "mimeType"));
        } else if (isEmpty(req.getContentBase64())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "contentBase64"));
        }

        // more sanitizing
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(req.getMimeType())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "mimeType"));
        }

        try {
            TbUser user = userService.updateUserProfilePic(context.getUserId(), req.getMimeType(), req.getContentBase64());
            return new UserResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserEntityToDto(user));
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

    @DELETE
    @Path("/me/profile-pic")
    @Operation(summary = "Delete public profile picture for current user")
    public UserResponse deleteCurrentUserProfilePic() {
        try {
            TbUser user = userService.deleteUserProfilePic(context.getUserId());
            return new UserResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserEntityToDto(user));
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

}
