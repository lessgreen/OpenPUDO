package less.green.openpudo.persistence.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_pudo")
@Getter
@Setter
@ToString
public class TbPudo implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "pudo_id", insertable = false, updatable = false)
    private Long pudoId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "update_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date updateTms;

    @Column(name = "business_name")
    private String businessName;

    @Column(name = "vat")
    private String vat;

    @Column(name = "phone_number")
    private String phoneNumber;

    @Column(name = "contact_notes")
    private String contactNotes;

    @Column(name = "profile_pic_id")
    private UUID profilePicId;

}
