package less.green.openpudo.persistence.dao;

import javax.enterprise.context.RequestScoped;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbDeviceToken;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class DeviceTokenDao extends BaseEntityDao<TbDeviceToken, String> {

    public DeviceTokenDao() {
        super(TbDeviceToken.class, "deviceToken");
    }

}
