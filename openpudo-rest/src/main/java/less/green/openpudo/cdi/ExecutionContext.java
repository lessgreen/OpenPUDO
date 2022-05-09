package less.green.openpudo.cdi;

import less.green.openpudo.common.dto.jwt.JwtPrivateClaims;
import lombok.Data;

import javax.enterprise.context.RequestScoped;
import java.util.UUID;

@RequestScoped
@Data
public class ExecutionContext {

    private final UUID executionId = UUID.randomUUID();
    private Long startTimestamp;
    private Long endTimestamp;
    private Long userId;
    private JwtPrivateClaims privateClaims;
    private String language;

}
