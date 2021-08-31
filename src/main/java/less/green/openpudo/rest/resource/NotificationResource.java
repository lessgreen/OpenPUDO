package less.green.openpudo.rest.resource;

import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.persistence.model.TbNotification;
import less.green.openpudo.persistence.service.NotificationService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.notification.NotificationListResponse;
import less.green.openpudo.rest.dto.scalar.LongResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/notifications")
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

    @Inject
    DtoMapper dtoMapper;

    @GET
    @Path("/")
    @Operation(summary = "Get notifications for current user")
    public NotificationListResponse getNotificationList(
            @Parameter(description = "Pagination limit", required = false) @DefaultValue("20") @QueryParam("limit") int limit,
            @Parameter(description = "Pagination offset", required = false) @DefaultValue("0") @QueryParam("offset") int offset,
            @HeaderParam("Application-Language") String applicationLanguage) {
        // sanitize input
        if (limit < 1) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "limit"));
        }
        if (offset < 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "offset"));
        }

        List<TbNotification> notifications = notificationService.getNotificationList(context.getUserId(), limit, offset);
        // localize notification
        for (TbNotification notification : notifications) {
            if (notification.getTitleParams() == null || notification.getTitleParams().length == 0) {
                notification.setTitle(localizationService.getLocalizedMessage(applicationLanguage, notification.getTitle()));
            } else {
                notification.setTitle(localizationService.getLocalizedMessage(applicationLanguage, notification.getTitle(), (Object[]) notification.getTitleParams()));
            }
            if (notification.getMessageParams() == null || notification.getMessageParams().length == 0) {
                notification.setMessage(localizationService.getLocalizedMessage(applicationLanguage, notification.getMessage()));
            } else {
                notification.setMessage(localizationService.getLocalizedMessage(applicationLanguage, notification.getMessage(), (Object[]) notification.getMessageParams()));
            }
        }
        return new NotificationListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapNotificationEntityToDto(notifications));
    }

    @GET
    @Path("/count")
    @Operation(summary = "Get count of unread notifications for current user")
    public LongResponse getUnreadNotificationCount() {
        long cnt = notificationService.getUnreadNotificationCount(context.getUserId());
        return new LongResponse(context.getExecutionId(), ApiReturnCodes.OK, cnt);
    }

    @POST
    @Path("/mark-as-read")
    @Operation(summary = "Mark all notifications for current user as read")
    public BaseResponse markNotificationsAsRead() {
        notificationService.markNotificationsAsRead(context.getUserId());
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

    @POST
    @Path("/{notificationId}/mark-as-read")
    @Operation(summary = "Mark notification with provided notificationId as read")
    public BaseResponse markNotificationAsRead(@PathParam(value = "notificationId") Long notificationId) {
        // checking permission
        TbNotification notification = notificationService.getNotification(notificationId);
        if (notification == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.resource_not_exists"));
        }
        if (!notification.getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
        }

        notificationService.markNotificationAsRead(notificationId);
        return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
    }

}
