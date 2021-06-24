package less.green.openpudo.persistence.dao;

import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbExternalFile;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class ExternalFileDao extends BaseEntityDao<TbExternalFile, UUID> {

    public ExternalFileDao() {
        super(TbExternalFile.class, "externalFileId");
    }

}
