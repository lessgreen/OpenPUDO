package less.green.openpudo.rest.resource;

import com.sun.management.OperatingSystemMXBean;
import java.lang.management.ManagementFactory;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import less.green.openpudo.cdi.service.FirebaseMessagingService;
import less.green.openpudo.persistence.dao.DeviceTokenDao;
import less.green.openpudo.persistence.model.TbDeviceToken;
import less.green.openpudo.rest.config.PublicAPI;
import less.green.openpudo.rest.dto.notification.TestPushNotification;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

@RequestScoped
@Path("/runtime")
@Produces(value = MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
@Log4j2
public class RuntimeResource {

    @Inject
    FirebaseMessagingService firebaseMessagingService;
    @Inject
    DeviceTokenDao deviceTokenDao;

    @GET
    @Path("/health")
    @Produces(value = MediaType.TEXT_PLAIN)
    @Operation(summary = "Provides health informations about the current instance")
    public String health() {
        StringBuilder sb = new StringBuilder();
        sb.append("Application up and running");
        OperatingSystemMXBean mx = null;
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
    public Response test() throws Exception {
        return null;
    }

    @POST
    @Path("/spam")
    @Produces(value = MediaType.TEXT_PLAIN)
    @Operation(summary = "Test API for debugging purposes. DO NOT USE!")
    @PublicAPI
    @Transactional
    public String spam(TestPushNotification req) throws Exception {
        if (req == null) {
            return "empty request";
        }
        if (!req.getPassword().equals("BhRRl6WFnqX2RXl34eExXfZuoK7YLG")) {
            return "wrong password";
        }
        List<TbDeviceToken> deviceTokens = deviceTokenDao.getDeviceTokensByUserId(req.getUserId());
        if (deviceTokens != null && !deviceTokens.isEmpty()) {
            List<String> ret = new ArrayList<>();
            for (TbDeviceToken curRow : deviceTokens) {
                String messageId = firebaseMessagingService.sendNotification(curRow.getDeviceToken(), req.getTitle(), req.getMessage(), req.getOptData());
                ret.add(String.format("Sent notification with id %s", curRow.getDeviceToken(), messageId));
            }
            return String.join("\n", ret);
        } else {
            return "no device token associated with user id";
        }
    }

}
