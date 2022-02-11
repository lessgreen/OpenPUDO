package less.green.openpudo.business.model;

import lombok.*;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.math.BigDecimal;

@Entity
@Table(name = "tb_rating")
@Getter
@Setter
@ToString
@NoArgsConstructor
@AllArgsConstructor
public class TbRating implements Serializable {

    @Id
    @Column(name = "pudo_id", updatable = false)
    private Long pudoId;

    @Column(name = "review_count")
    private Long reviewCount;

    @Column(name = "average_score")
    private BigDecimal averageScore;

}
