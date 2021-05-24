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
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.service.UserService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
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

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;
    @Inject
    DtoMapper dtoMapper;

    @Inject
    UserService userService;

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

}
