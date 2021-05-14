package less.green.openpudo.rest.config;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.quarkus.runtime.configuration.ProfileManager;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.Set;
import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.InternalServerErrorException;
import javax.ws.rs.Priorities;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import static javax.ws.rs.core.HttpHeaders.AUTHORIZATION;
import javax.ws.rs.ext.Provider;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.common.dto.JwtPayload;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;

@Provider
@Priority(Priorities.AUTHENTICATION)
@Log4j2
public class AccessTokenFilter implements ContainerRequestFilter {

    public static final String BEARER_AUTHENTICATION_SCHEME = "Bearer";
    private static final Set<String> PUBLIC_RESOURCES = new HashSet<>(Arrays.asList(
            "/auth/register",
            "/auth/login",
            "/auth/renew"
    ));

    @Inject
    ExecutionContext context;

    @Inject
    JwtService jwtService;
    @Inject
    LocalizationService localizationService;

    @Override
    public void filter(ContainerRequestContext requestContext) {
        if (PUBLIC_RESOURCES.contains(requestContext.getUriInfo().getPath())) {
            return;
        }

        // check for backdoor access
        if ("dev".equals(ProfileManager.getActiveProfile())) {
            context.setUserId(0L);
            return;
        }

        // check for access token. header must be in the form
        // Authorization: Bearer eyJhbGci...<snip>...yu5CSpyHI
        String authorizationHeader = requestContext.getHeaderString(AUTHORIZATION);
        if (isEmpty(authorizationHeader)) {
            log.debug("[{}] Authorization failed: missing header", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage("error.auth.invalid_access_token"));
        }
        String[] split = authorizationHeader.split("\\s", -1);
        if (!split[0].equals(BEARER_AUTHENTICATION_SCHEME)) {
            log.debug("[{}] Authorization failed: wrong authentication scheme", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage("error.auth.invalid_access_token"));
        }
        if (split.length < 2) {
            log.debug("[{}] Authorization failed: missing token", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage("error.auth.invalid_access_token"));
        }

        // checking signature
        String accessToken = split[1].trim();
        if (jwtService.verifyAccessTokenSignature(accessToken) == false) {
            log.debug("[{}] Authorization failed: invalid token signature", context.getExecutionId());
            throw new ApiException(ApiReturnCodes.INVALID_JWT_TOKEN, localizationService.getMessage("error.auth.invalid_access_token"));
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
            throw new ApiException(ApiReturnCodes.EXPIRED_JWT_TOKEN, localizationService.getMessage("error.auth.expired_access_token"));
        }

        // if everything went fine, populate context with userId
        context.setUserId(payload.getSub());
    }

}
