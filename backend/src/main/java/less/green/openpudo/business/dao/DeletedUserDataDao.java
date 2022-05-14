package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbDeletedUserData;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import java.util.UUID;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class DeletedUserDataDao extends BaseEntityDao<TbDeletedUserData, UUID> {

    public DeletedUserDataDao() {
        super(TbDeletedUserData.class, "userDataId");
    }

}
