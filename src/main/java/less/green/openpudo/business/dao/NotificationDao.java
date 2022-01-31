package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbNotification;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.Collections;
import java.util.Date;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class NotificationDao extends BaseEntityDao<TbNotification, Long> {

    public NotificationDao() {
        super(TbNotification.class, "notificationId");
    }

    public int removeQueuedNotificationFavourite(Long customerUserId, Long pudoId) {
        String qs = "DELETE FROM TbNotificationFavourite t WHERE t.queuedFlag = true AND t.customerUserId = :customerUserId AND t.pudoId = :pudoId";
        Query q = em.createQuery(qs);
        q.setParameter("customerUserId", customerUserId);
        q.setParameter("pudoId", pudoId);
        return q.executeUpdate();
    }

    public List<Long> getQueuedNotificationFavouriteIdsToSend() {
        String qs = "SELECT t.notificationId FROM TbNotification t WHERE t.queuedFlag = true AND t.dueTms <= :now";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("now", new Date());
        List<Long> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
