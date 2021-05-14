package less.green.openpudo.rest.config;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.info.Info;

@ApplicationPath("/api")
@OpenAPIDefinition(info = @Info(title = "OpenPUDO", version = "v1"))
public class RestApplication extends Application {
}
