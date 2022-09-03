package less.green.openpudo.rest.config;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.ext.Provider;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;

import static less.green.openpudo.common.Encoders.OBJECT_MAPPER_COMPACT;
import static less.green.openpudo.common.StreamUtils.readAllBytesFromInputStream;
import static less.green.openpudo.common.StringUtils.isEmpty;

@Provider
@Priority(3)
@Log4j2
public class RestBodyFilter implements ContainerRequestFilter, ContainerResponseFilter {

    @Inject
    ExecutionContext context;

    @Context
    ResourceInfo resourceInfo;

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        if (requestContext.hasEntity() && !resourceInfo.getResourceMethod().isAnnotationPresent(BinaryAPI.class)) {
            byte[] entityBytes;
            try (InputStream originalStream = requestContext.getEntityStream()) {
                entityBytes = readAllBytesFromInputStream(originalStream);
            }
            ByteArrayInputStream clonedStream = new ByteArrayInputStream(entityBytes);
            requestContext.setEntityStream(clonedStream);
            String entity = new String(entityBytes, StandardCharsets.UTF_8);
            if (!isEmpty(entity)) {
                context.setRequestBody(entity);
                log.trace("[{}] Request: {}", context.getExecutionId(), entity);
            }
        }
    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        // skip processing of call without a matched method
        if (resourceInfo.getResourceMethod() == null) {
            return;
        }
        if (responseContext.hasEntity() && !resourceInfo.getResourceMethod().isAnnotationPresent(BinaryAPI.class) && BaseResponse.class.isAssignableFrom(responseContext.getEntity().getClass())) {
            String entity = OBJECT_MAPPER_COMPACT.writeValueAsString(responseContext.getEntity());
            context.setResponseBody(entity);
            log.trace("[{}] Response: {}", context.getExecutionId(), entity);
        }
    }

}
