package less.green.openpudo.rest.config;

import java.io.IOException;
import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import static less.green.openpudo.common.FormatUtils.smartElapsed;
import lombok.extern.log4j.Log4j2;

@Provider
@PreMatching
@Priority(1)
@Log4j2
public class RestFilter implements ContainerRequestFilter, ContainerResponseFilter {

    @Inject
    ExecutionContext context;

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        context.setStartTimestamp(System.nanoTime());
        if (log.isDebugEnabled()) {
            log.debug("[{}] {} {}{}", context.getExecutionId(), requestContext.getMethod(), requestContext.getUriInfo().getRequestUri().getPath(),
                    requestContext.getUriInfo().getRequestUri().getQuery() == null ? "" : "?" + requestContext.getUriInfo().getRequestUri().getQuery());
        }

    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        context.setEndTimestamp(System.nanoTime());
        if (log.isDebugEnabled()) {
            log.debug("[{}] {} {}", context.getExecutionId(), responseContext.getStatus(), smartElapsed(context.getEndTimestamp() - context.getStartTimestamp()));
        }
    }

}
