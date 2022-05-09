package less.green.openpudo.common.dto.tuple;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Septet<A, B, C, D, E, F, G> {

    private A value0;
    private B value1;
    private C value2;
    private D value3;
    private E value4;
    private F value5;
    private G value6;

}
