package less.green.openpudo.rest.config;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerResponseContext;
import javax.ws.rs.container.ContainerResponseFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import static less.green.openpudo.common.Encoders.OBJECT_MAPPER;
import static less.green.openpudo.common.FormatUtils.smartElapsed;
import static less.green.openpudo.common.StreamUtils.readAllBytesFromInputStream;
import static less.green.openpudo.common.StringUtils.isEmpty;
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
        if (log.isTraceEnabled() && requestContext.hasEntity()) {
            byte[] entityBytes;
            try (InputStream originalStream = requestContext.getEntityStream()) {
                entityBytes = readAllBytesFromInputStream(originalStream);
            }
            ByteArrayInputStream clonedStream = new ByteArrayInputStream(entityBytes);
            requestContext.setEntityStream(clonedStream);
            String entity = new String(entityBytes, StandardCharsets.UTF_8);
            if (!isEmpty(entity)) {
                log.trace("[{}] Request: {}", context.getExecutionId(), entity);
            }
        }
    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        if (log.isTraceEnabled() && responseContext.hasEntity()) {
            log.trace("[{}] Response: {}", context.getExecutionId(), OBJECT_MAPPER.writeValueAsString(responseContext.getEntity()));
        }
        context.setEndTimestamp(System.nanoTime());
        if (log.isDebugEnabled()) {
            log.debug("[{}] {} {}", context.getExecutionId(), responseContext.getStatus(), smartElapsed(context.getEndTimestamp() - context.getStartTimestamp()));
        }
    }

}
