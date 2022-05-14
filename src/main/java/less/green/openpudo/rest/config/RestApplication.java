package less.green.openpudo.rest.config;

import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.enums.SecuritySchemeType;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.security.SecurityScheme;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

@ApplicationPath("/api/v2")
@OpenAPIDefinition(info = @Info(title = "OpenPUDO", version = "v2"))
@SecurityScheme(securitySchemeName = "JWT", type = SecuritySchemeType.HTTP, scheme = "Bearer")
public class RestApplication extends Application {
}
