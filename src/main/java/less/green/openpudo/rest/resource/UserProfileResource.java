package less.green.openpudo.rest.resource;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.persistence.model.TbUserProfile;
import less.green.openpudo.persistence.service.UserService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.user.UserProfile;
import less.green.openpudo.rest.dto.user.UserProfileResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

@RequestScoped
@Path("/users")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class UserProfileResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;
    @Inject
    DtoMapper dtoMapper;

    @Inject
    UserService userService;

    @GET
    @Path("/{userId}/profile")
    @Operation(summary = "Get public profile for user with provided userId")
    public UserProfileResponse getUserProfileById(@PathParam(value = "userId") Long userId) {
        TbUserProfile userProfile = userService.getUserProfileById(userId);
        return new UserProfileResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserProfileEntityToDto(userProfile));
    }

    @GET
    @Path("/me/profile")
    @Operation(summary = "Get public profile for current user")
    public UserProfileResponse getCurrentUserProfile() {
        return getUserProfileById(context.getUserId());
    }

    @PUT
    @Path("/me/profile")
    @Operation(summary = "Update public profile for current user")
    public UserProfileResponse updateCurrentUserProfile(UserProfile req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getFirstName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "firstName"));
        } else if (isEmpty(req.getLastName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lastName"));
        }

        TbUserProfile userProfile = userService.updateCurrentUserProfile(context.getUserId(), req);
        return new UserProfileResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserProfileEntityToDto(userProfile));
    }

}
