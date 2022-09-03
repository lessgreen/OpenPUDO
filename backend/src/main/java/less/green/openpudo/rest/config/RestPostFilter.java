package less.green.openpudo.rest.config;

import io.quarkus.runtime.configuration.ProfileManager;
import io.vertx.core.http.HttpServerRequest;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.Encoders;
import less.green.openpudo.rest.dto.BaseResponse;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.ext.Provider;
import java.io.IOException;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Provider
@Priority(2)
@Log4j2
public class RestPostFilter implements ContainerRequestFilter, ContainerResponseFilter {

    private static final String X_FORWARDED_FOR_HEADER = "X-Forwarded-For";
    private static final String LANGUAGE_HEADER = "Application-Language";
    private static final String USER_AGENT_HEADER = "User-Agent";

    @Inject
    ExecutionContext context;

    @Context
    HttpServerRequest httpServerRequest;

    @Context
    ResourceInfo resourceInfo;

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        context.setRequestHttpMethod(requestContext.getMethod());
        context.setRequestUri(requestContext.getUriInfo().getRequestUri().getPath() + (requestContext.getUriInfo().getRequestUri().getQuery() == null ? "" : "?" + requestContext.getUriInfo().getRequestUri().getQuery()));
        context.setResourceMethod(resourceInfo.getResourceMethod().getDeclaringClass().getSimpleName() + "::" + resourceInfo.getResourceMethod().getName());
        if (!isEmpty(requestContext.getHeaderString(X_FORWARDED_FOR_HEADER))) {
            context.setRemoteAddress(requestContext.getHeaderString(X_FORWARDED_FOR_HEADER).trim());
        } else if (httpServerRequest.remoteAddress() != null) {
            context.setRemoteAddress(httpServerRequest.remoteAddress().hostAddress());
        }
        context.setRequestHeaders(Encoders.writeValueAsStringSafe(requestContext.getHeaders()));
        if (!isEmpty(requestContext.getHeaderString(LANGUAGE_HEADER))) {
            context.setLanguage(requestContext.getHeaderString(LANGUAGE_HEADER).trim());
        } else if ("dev".equals(ProfileManager.getActiveProfile())) {
            context.setLanguage("it");
        }
        if (!isEmpty(requestContext.getHeaderString(USER_AGENT_HEADER))) {
            context.setUserAgent(requestContext.getHeaderString(USER_AGENT_HEADER));
        }
    }

    @Override
    public void filter(ContainerRequestContext requestContext, ContainerResponseContext responseContext) throws IOException {
        // skip processing of call without a matched method
        if (resourceInfo.getResourceMethod() == null) {
            return;
        }
        context.setResponseHttpStatusCode(responseContext.getStatus());
        if (responseContext.hasEntity() && BaseResponse.class.isAssignableFrom(responseContext.getEntity().getClass())) {
            context.setReturnCode(((BaseResponse) responseContext.getEntity()).getReturnCode());
        }

    }

}
