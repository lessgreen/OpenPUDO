package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.NotificationService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.notification.Notification;
import less.green.openpudo.rest.dto.notification.NotificationListResponse;
import less.green.openpudo.rest.dto.scalar.LongResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.util.List;

@RequestScoped
@Path("/notification")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class NotificationResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    NotificationService notificationService;

    @GET
    @Path("/")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get notifications for current user")
    public NotificationListResponse getNotifications(
            @Parameter(description = "Pagination limit") @DefaultValue("20") @QueryParam("limit") int limit,
            @Parameter(description = "Pagination offset") @DefaultValue("0") @QueryParam("offset") int offset) {
        // sanitize input
        if (limit < 1) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "limit"));
        }
        if (offset < 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "offset"));
        }

        List<Notification> ret = notificationService.getNotifications(limit, offset);
        return new NotificationListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/count")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get count of unread notifications for current user")
    public LongResponse getUnreadNotificationCount() {
        long cnt = notificationService.getUnreadNotificationCount();
        return new LongResponse(context.getExecutionId(), ApiReturnCodes.OK, cnt);
    }

    @POST
    @Path("/mark-as-read")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Mark all notifications for current user as read")
    public BaseResponse markNotificationsAsRead() {
        notificationService.markNotificationsAsRead();
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/{notificationId}/mark-as-read")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Mark notification with provided notificationId as read")
    public BaseResponse markNotificationAsRead(@PathParam(value = "notificationId") Long notificationId) {
        notificationService.markNotificationAsRead(notificationId);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

}
