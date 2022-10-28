package less.green.openpudo.cdi;

import com.fasterxml.jackson.annotation.JsonFormat;
import less.green.openpudo.common.dto.jwt.JwtPrivateClaims;
import lombok.Data;

import javax.enterprise.context.RequestScoped;
import java.time.Instant;
import java.util.UUID;

@RequestScoped
@Data
public class ExecutionContext {

    private final UUID executionId = UUID.randomUUID();
    // jwt fields
    private Long userId;
    private JwtPrivateClaims privateClaims;
    // request
    private Long startNanos;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant startTimestamp;
    private String requestHttpMethod;
    private String requestUri;
    private String resourceMethod;
    private String remoteAddress;
    private String requestHeaders;
    private String requestBody;
    // response
    private Long endNanos;
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private Instant endTimestamp;
    private int responseHttpStatusCode;
    private Integer returnCode;
    private String responseBody;
    private String stackTrace;
    // application specific fields, extracted or calculated for easier access during execution
    private String language;
    private String userAgent;

}
