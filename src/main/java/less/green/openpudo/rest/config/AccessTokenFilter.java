package less.green.openpudo.rest.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.quarkus.runtime.configuration.ProfileManager;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.JwtPayload;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.InternalServerErrorException;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ResourceInfo;
import javax.ws.rs.core.Context;
import javax.ws.rs.ext.Provider;
import java.util.Date;

import static javax.ws.rs.core.HttpHeaders.AUTHORIZATION;
import static less.green.openpudo.common.StringUtils.isEmpty;

@Provider
@Priority(Priorities.AUTHENTICATION)
@Log4j2
public class AccessTokenFilter implements ContainerRequestFilter {

    private static final String BEARER_AUTHENTICATION_SCHEME = "Bearer";

    @Inject
    ExecutionContext context;

    @Context
    ResourceInfo resourceInfo;

    @Inject
    JwtService jwtService;
    @Inject
    LocalizationService localizationService;

    @Override
    public void filter(ContainerRequestContext requestContext) {
        if (resourceInfo.getResourceMethod().isAnnotationPresent(PublicAPI.class)) {
            return;
        }

        // check for access token. header must be in the form
        // Authorization: Bearer eyJhbGci...<snip>...yu5CSpyHI
        String authorizationHeader = requestContext.getHeaderString(AUTHORIZATION);

        // backdoor access
        if ("dev".equals(ProfileManager.getActiveProfile()) && authorizationHeader == null) {
            context.setUserId(1L);
            return;
        }

        // get application language, if sent by client
        String language = requestContext.getHeaderString("Application-Language");

        if (isEmpty(authorizationHeader)) {
            log.debug("[{}] Authorization failed: missing header", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(language, "error.auth.invalid_access_token"));
        }
        String[] split = authorizationHeader.split("\\s", -1);
        if (!split[0].equals(BEARER_AUTHENTICATION_SCHEME)) {
            log.debug("[{}] Authorization failed: wrong authentication scheme", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(language, "error.auth.invalid_access_token"));
        }
        if (split.length < 2) {
            log.debug("[{}] Authorization failed: missing token", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(language, "error.auth.invalid_access_token"));
        }

        // checking signature
        String accessToken = split[1].trim();
        if (!jwtService.verifyAccessTokenSignature(accessToken)) {
            log.debug("[{}] Authorization failed: invalid token signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(language, "error.auth.invalid_access_token"));
        }
        // if access token is valid, checking for expiration
        JwtPayload payload;
        try {
            payload = jwtService.decodePayload(accessToken.split("\\.", -1)[1]);
        } catch (JsonProcessingException ex) {
            // we have a valid signature for an unparsable payload, this should NEVER happen, triggering an internal server error
            log.error("[{}] Authorization failed: invalid token payload with valid signature", context.getExecutionId());
            throw new InternalServerErrorException();
        }
        if (new Date().after(payload.getExp())) {
            log.debug("[{}] Authorization failed: token expired", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.EXPIRED_JWT_TOKEN, localizationService.getMessage(language, "error.auth.expired_access_token"));
        }

        // if everything went fine, populate context with userId
        context.setUserId(payload.getSub());
    }

}
