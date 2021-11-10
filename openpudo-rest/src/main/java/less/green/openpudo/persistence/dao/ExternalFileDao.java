package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.model.TbExternalFile;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import java.util.UUID;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class ExternalFileDao extends BaseEntityDao<TbExternalFile, UUID> {

    public ExternalFileDao() {
        super(TbExternalFile.class, "externalFileId");
    }

}
