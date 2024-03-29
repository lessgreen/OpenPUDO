package less.green.openpudo.rest.config;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.*;
import javax.ws.rs.ext.Provider;
import java.io.IOException;

import static less.green.openpudo.common.FormatUtils.smartElapsed;

@Provider
@PreMatching
@Priority(1)
@Log4j2
public class RestFilter implements ContainerRequestFilter, ContainerResponseFilter {

    @Inject
    ExecutionContext context;

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        // skip filtering for preflight requests
        if (requestContext.getMethod().equals("OPTIONS")) {
            return;
        }
        context.setStartTimestamp(System.nanoTime());
        log.info("[{}] {} {}{}", context.getExecutionId(), requestContext.getMethod(), requestContext.getUriInfo().getRequestUri().getPath(),
                requestContext.getUriInfo().getRequestUri().getQuery() == null ? "" : "?" + requestContext.getUriInfo().getRequestUri().getQuery());

    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        // skip filtering for preflight requests
        if (requestContext.getMethod().equals("OPTIONS")) {
            return;
        }
        context.setEndTimestamp(System.nanoTime());
        log.info("[{}] {} {}", context.getExecutionId(),
                responseContext.hasEntity() && BaseResponse.class.isAssignableFrom(responseContext.getEntity().getClass()) ? ((BaseResponse) responseContext.getEntity()).getReturnCode() : responseContext.getStatus(),
                smartElapsed(context.getEndTimestamp() - context.getStartTimestamp()));
    }

}
