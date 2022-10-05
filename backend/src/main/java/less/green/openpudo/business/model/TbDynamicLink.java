package less.green.openpudo.business.model;

import less.green.openpudo.business.model.usertype.DynamicLinkRoute;
import less.green.openpudo.business.model.usertype.DynamicLinkRouteConverter;
import less.green.openpudo.business.model.usertype.JsonConverter;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "tb_dynamic_link")
@Getter
@Setter
@ToString
public class TbDynamicLink implements Serializable {

    @Id
    @Column(name = "dynamic_link_id", updatable = false)
    private UUID dynamicLinkId;

    @Column(name = "dynamic_link_url")
    private String dynamicLinkUrl;

    @Column(name = "create_tms")
    private Instant createTms;

    @Column(name = "access_tms")
    private Instant accessTms;

    @Column(name = "used_tms")
    private Instant usedTms;

    @Column(name = "reusable_flag")
    private Boolean reusableFlag;

    @Column(name = "origin_user_id")
    private Long originUserId;

    @Column(name = "route")
    @Convert(converter = DynamicLinkRouteConverter.class)
    private DynamicLinkRoute route;

    @Column(name = "data", columnDefinition = "jsonb")
    @Convert(converter = JsonConverter.class)
    private Map<String, Object> data;

}
