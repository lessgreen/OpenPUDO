package less.green.openpudo.cdi.service;

import io.quarkus.runtime.Startup;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import kong.unirest.Unirest;
import lombok.extern.log4j.Log4j2;

@ApplicationScoped
@Startup
@Log4j2
public class UnirestInitializerService {

    @PostConstruct
    void init() {
        // hot reload quirk
        Unirest.config().reset();
        Unirest.config()
                .socketTimeout(5000)
                .connectTimeout(5000);
    }

}
