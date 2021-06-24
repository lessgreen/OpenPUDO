package less.green.openpudo.rest.config.exception;

import javax.inject.Inject;
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
 * Since the exception passed unhandled, this is the right place to log the stacktrace, but hiding the exception message in the response.
 */
@Provider
@Log4j2
public class InternalServerErrorExceptionMapper implements ExceptionMapper<Exception> {

    @Inject
    ExecutionContext context;

    @Override
    public Response toResponse(Exception exception) {
        log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(exception));
        BaseResponse resp = new BaseResponse(context.getExecutionId(), ApiReturnCodes.INTERNAL_SERVER_ERROR, "Unhandled exception");
        return Response.serverError().entity(resp).build();
    }

}
