package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUserPudoRelation;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class UserPudoRelationDao extends BaseEntityDao<TbUserPudoRelation, Long> {

    public UserPudoRelationDao() {
        super(TbUserPudoRelation.class, "userPudoRelationId");
    }

}
