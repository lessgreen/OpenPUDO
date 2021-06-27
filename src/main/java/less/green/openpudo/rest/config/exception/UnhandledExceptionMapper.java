package less.green.openpudo.rest.config.exception;

import javax.inject.Inject;
import javax.ws.rs.NotFoundException;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

/**
 * This mapper intercepts unhandled exceptions
 * <br>
 * If an Exception is not handled before, it means there is basically nothing we can do about it, so we just map to a 500 Internal Server Error.<br>
 * This is the right place to log the stacktrace, but hiding the exception message in the response.<br>
 * Since this is a last resort handler, it will match NotFoundException thrown by JAX-RS too, so we map them to a 404.
 */
@Provider
@Log4j2
public class UnhandledExceptionMapper implements ExceptionMapper<Exception> {

    @Inject
    ExecutionContext context;

    @Override
    public Response toResponse(Exception ex) {
        if (ex instanceof NotFoundException) {
            BaseResponse resp = new BaseResponse(context.getExecutionId(), ApiReturnCodes.RESOURCE_NOT_FOUND, Response.Status.NOT_FOUND.getReasonPhrase());
            return Response.status(Response.Status.NOT_FOUND).entity(resp).build();
        }
        log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
        BaseResponse resp = new BaseResponse(context.getExecutionId(), ApiReturnCodes.INTERNAL_SERVER_ERROR, Response.Status.INTERNAL_SERVER_ERROR.getReasonPhrase());
        return Response.serverError().entity(resp).build();
    }

}
