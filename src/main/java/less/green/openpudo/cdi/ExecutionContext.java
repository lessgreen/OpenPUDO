package less.green.openpudo.cdi;

import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import lombok.Data;

@RequestScoped
@Data
public class ExecutionContext {

    private final UUID executionId = UUID.randomUUID();
    private Long startTimestamp;
    private Long endTimestamp;
    private Long userId;

}
