package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbDeviceToken;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.Collections;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class DeviceTokenDao extends BaseEntityDao<TbDeviceToken, String> {

    public DeviceTokenDao() {
        super(TbDeviceToken.class, "deviceToken");
    }

    public List<TbDeviceToken> getDeviceTokens(Long userId) {
        String qs = "SELECT t FROM TbDeviceToken t WHERE t.userId = :userId";
        TypedQuery<TbDeviceToken> q = em.createQuery(qs, TbDeviceToken.class);
        q.setParameter("userId", userId);
        List<TbDeviceToken> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public int removeFailedDeviceTokens() {
        String qs = "DELETE FROM TbDeviceToken t WHERE t.failureCount >= 10";
        Query q = em.createQuery(qs);
        return q.executeUpdate();
    }

}
