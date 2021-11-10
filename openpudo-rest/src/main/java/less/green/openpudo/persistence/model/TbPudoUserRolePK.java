package less.green.openpudo.persistence.model;

import lombok.Data;

import java.io.Serializable;

@Data
public class TbPudoUserRolePK implements Serializable {

    private Long userId;
    private Long pudoId;

}
