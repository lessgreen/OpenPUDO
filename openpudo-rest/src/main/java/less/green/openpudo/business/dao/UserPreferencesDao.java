package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUserPreferences;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class UserPreferencesDao extends BaseEntityDao<TbUserPreferences, Long> {

    public UserPreferencesDao() {
        super(TbUserPreferences.class, "userId");
    }

}
