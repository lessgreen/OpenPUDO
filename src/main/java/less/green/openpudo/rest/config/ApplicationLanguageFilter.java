package less.green.openpudo.rest.config;

import less.green.openpudo.cdi.ExecutionContext;
import lombok.extern.log4j.Log4j2;

import javax.annotation.Priority;
import javax.inject.Inject;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.ext.Provider;
import java.io.IOException;

import static less.green.openpudo.common.StringUtils.isEmpty;

@Provider
@Priority(3)
@Log4j2
public class ApplicationLanguageFilter implements ContainerRequestFilter {

    private static final String LANGUAGE_HEADER = "Application-Language";

    @Inject
    ExecutionContext context;

    @Override
    public void filter(ContainerRequestContext requestContext) throws IOException {
        // get application language, if sent by client, and save it into context
        String language = requestContext.getHeaderString(LANGUAGE_HEADER);
        if (!isEmpty(language)) {
            context.setLanguage(language.trim());
        }
    }

}
