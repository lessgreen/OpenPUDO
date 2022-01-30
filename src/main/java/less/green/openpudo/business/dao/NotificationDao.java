package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbNotification;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.Query;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class NotificationDao extends BaseEntityDao<TbNotification, Long> {

    public NotificationDao() {
        super(TbNotification.class, "notificationId");
    }

    public int removeQueuedNotificationRelation(Long customerUserId, Long pudoId) {
        String qs = "DELETE FROM TbNotificationRelation t WHERE t.queuedFlag = true AND t.customerUserId = :customerUserId AND t.pudoId = :pudoId";
        Query q = em.createQuery(qs);
        q.setParameter("customerUserId", customerUserId);
        q.setParameter("pudoId", pudoId);
        return q.executeUpdate();
    }

}
