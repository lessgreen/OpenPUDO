package less.green.openpudo.common.dto.tuple;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Quartet<A, B, C, D> {

    private A value0;
    private B value1;
    private C value2;
    private D value3;

}
