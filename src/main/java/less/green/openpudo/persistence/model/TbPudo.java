package less.green.openpudo.persistence.model;

import java.io.Serializable;
import java.util.Date;
import java.util.UUID;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

@Entity
@Table(name = "tb_pudo")
@Getter @Setter @ToString
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
