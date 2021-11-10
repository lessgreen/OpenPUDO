package less.green.openpudo.persistence.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

@Entity
@Table(name = "tb_external_file")
@Getter
@Setter
@ToString
public class TbExternalFile implements Serializable {

    @Id
    @Column(name = "external_file_id", updatable = false)
    private UUID externalFileId;

    @Column(name = "create_tms")
    @Temporal(TemporalType.TIMESTAMP)
    private Date createTms;

    @Column(name = "mime_type")
    private String mimeType;

}
