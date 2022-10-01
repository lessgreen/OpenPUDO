package less.green.openpudo.rest.resource;

import com.sun.management.OperatingSystemMXBean;
import less.green.openpudo.cdi.service.FirebaseDynamicLinksService;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.lang.management.ManagementFactory;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.UUID;

@RequestScoped
@Path("/runtime")
@Produces(value = MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
@Log4j2
public class RuntimeResource {

    @Inject
    FirebaseDynamicLinksService firebaseDynamicLinksService;

    @GET
    @Path("/health")
    @Produces(value = MediaType.TEXT_PLAIN)
    @Operation(summary = "Provides health info about the current instance")
    public String health() {
        StringBuilder sb = new StringBuilder();
        sb.append("Application up and running");
        OperatingSystemMXBean mx;
        try {
            mx = (OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
        } catch (Exception ex) {
            sb.append("\n");
            sb.append("Lookup of system resources unavailable");
            return sb.toString();
        }
        sb.append("\n");
        sb.append(String.format("Committed memory: %s MiB", BigDecimal.valueOf(mx.getCommittedVirtualMemorySize()).divide(BigDecimal.valueOf(1024 * 1024), 0, RoundingMode.HALF_UP)));
        sb.append("\n");
        sb.append(String.format("Free memory: %s MiB", BigDecimal.valueOf(mx.getFreePhysicalMemorySize()).divide(BigDecimal.valueOf(1024 * 1024), 0, RoundingMode.HALF_UP)));
        sb.append("\n");
        sb.append(String.format("Process CPU load: %s%%", BigDecimal.valueOf(mx.getProcessCpuLoad()).multiply(BigDecimal.valueOf(100)).setScale(1, RoundingMode.HALF_UP)));
        sb.append("\n");
        sb.append(String.format("System CPU load: %s%%", BigDecimal.valueOf(mx.getSystemCpuLoad()).multiply(BigDecimal.valueOf(100)).setScale(1, RoundingMode.HALF_UP)));
        return sb.toString();
    }

    @GET
    @Path("/test")
    @Operation(summary = "Test API for debugging purposes. DO NOT USE!")
    @Transactional(Transactional.TxType.REQUIRED)
    public Response test() throws Exception {
        UUID linkId = UUID.randomUUID();
        log.info("UUID: {}", linkId);
        var dynamicLink = firebaseDynamicLinksService.generateDynamicLink(linkId);
        log.info("Generated dynamic link: {}", dynamicLink);
        return null;
    }

}
