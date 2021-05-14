package less.green.openpudo.rest.config.exception;

import javax.inject.Inject;
import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

@Provider
@Log4j2
public class ApiExceptionExceptionMapper implements ExceptionMapper<ApiException> {

    @Inject
    ExecutionContext context;

    @Override
    public Response toResponse(ApiException ex) {
        BaseResponse resp = new BaseResponse(context.getExecutionId(), ex.getReturnCode(), ex.getMessage());
        return Response.ok(resp).build();
    }

}
