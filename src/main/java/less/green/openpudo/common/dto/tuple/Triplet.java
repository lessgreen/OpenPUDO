package less.green.openpudo.common.dto.tuple;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Triplet<A, B, C> {

    private A value0;
    private B value1;
    private C value2;

}
