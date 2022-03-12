package less.green.openpudo.rest.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.quarkus.runtime.configuration.ProfileManager;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.jwt.JwtPayload;
import less.green.openpudo.rest.config.annotation.ProtectedAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ResourceInfo;
import javax.ws.rs.core.Context;
import javax.ws.rs.ext.Provider;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Provider
@Priority(Priorities.AUTHENTICATION)
@Log4j2
public class AccessTokenFilter implements ContainerRequestFilter {

    private static final String AUTHORIZATION_HEADER = "Authorization";
    private static final String AUTHORIZATION_REGEX = "Bearer (?<token>[\\w-]+\\.[\\w-]+\\.[\\w-]+)";
    private static final Pattern AUTHORIZATION_PATTERN = Pattern.compile(AUTHORIZATION_REGEX);

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
        // allow unrestricted access to public api
        if (resourceInfo.getResourceMethod().isAnnotationPresent(PublicAPI.class)) {
            return;
        }

        // check for access token. header must be in the form
        // Authorization: Bearer eyJhbGci...<snip>...yu5CSpyHI
        String authorizationHeader = requestContext.getHeaderString(AUTHORIZATION_HEADER);

        // backdoor access
        if ("dev".equals(ProfileManager.getActiveProfile()) && authorizationHeader == null) {
            context.setUserId(1L);
            return;
        }

        if (isEmpty(authorizationHeader)) {
            log.debug("[{}] Authorization failed: missing Authorization header", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }
        Matcher m = AUTHORIZATION_PATTERN.matcher(authorizationHeader);
        if (!m.matches()) {
            log.debug("[{}] Authorization failed: invalid Authorization header", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }

        // checking signature
        String accessToken = m.group("token");
        if (!jwtService.isValidSignature(accessToken)) {
            log.debug("[{}] Authorization failed: invalid token signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }

        // decoding token
        JwtPayload payload;
        try {
            payload = jwtService.decodePayload(accessToken.split("\\.", -1)[1]);
        } catch (JsonProcessingException ex) {
            // we have a valid signature for a not parsable payload, this should NEVER happen
            log.fatal("[{}] Authorization failed: invalid token payload with valid signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }

        // checking for expiration
        if (new Date().after(payload.getExp())) {
            log.debug("[{}] Authorization failed: token expired", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.EXPIRED_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.expired_access_token"));
        }

        // if caller is a guest, we allow access to non-private api only
        if (payload.getSub() == null && !resourceInfo.getResourceMethod().isAnnotationPresent(ProtectedAPI.class)) {
            log.debug("[{}] Authorization failed: accessing private api with guest token", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.EXPIRED_JWT_TOKEN, localizationService.getMessage(context.getLanguage(), "error.auth.invalid_access_token"));
        }

        // if everything went fine, populate context
        context.setUserId(payload.getSub());
        context.setPrivateClaims(payload.getPrivateClaims());
    }

}
