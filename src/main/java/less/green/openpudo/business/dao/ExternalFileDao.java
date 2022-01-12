package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbExternalFile;

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
