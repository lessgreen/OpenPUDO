package less.green.openpudo.business.model;

import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.Table;
import java.io.Serializable;
import java.time.Instant;
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
    private Instant createTms;

    @Column(name = "mime_type")
    private String mimeType;

}
