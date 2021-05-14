package less.green.openpudo.rest.config.exception;

import javax.inject.Inject;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

@Provider
@Log4j2
public class InternalServerErrorExceptionMapper implements ExceptionMapper<Exception> {

    @Inject
    ExecutionContext context;

    @Override
    public Response toResponse(Exception ex) {
        log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
        BaseResponse resp = new BaseResponse(context.getExecutionId(), 500, "Unhandled exception");
        return Response.serverError().entity(resp).build();
    }

}
