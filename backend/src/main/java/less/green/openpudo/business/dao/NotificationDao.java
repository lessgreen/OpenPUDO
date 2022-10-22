package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbNotification;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.time.Instant;
import java.util.Collections;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class NotificationDao extends BaseEntityDao<TbNotification, Long> {

    public NotificationDao() {
        super(TbNotification.class, "notificationId");
    }

    public List<TbNotification> getNotifications(Long userId, int limit, int offset) {
        String qs = "SELECT t FROM TbNotification t WHERE t.userId = :userId AND t.queuedFlag = false ORDER BY t.createTms DESC";
        TypedQuery<TbNotification> q = em.createQuery(qs, TbNotification.class);
        q.setParameter("userId", userId);
        q.setMaxResults(limit);
        q.setFirstResult(offset);
        List<TbNotification> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public long getUnreadNotificationCount(Long userId) {
        String qs = "SELECT COUNT(t) FROM TbNotification t WHERE t.userId = :userId AND t.queuedFlag = false AND t.readTms IS NULL";
        TypedQuery<Long> q = em.createQuery(qs, Long.class);
        q.setParameter("userId", userId);
        return q.getSingleResult();
    }

    public int markNotificationsAsRead(Long userId) {
        String qs = "UPDATE TbNotification t SET t.readTms = :now WHERE t.userId = :userId AND t.queuedFlag = false AND t.readTms IS NULL";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        q.setParameter("now", Instant.now());
        return q.executeUpdate();
    }

    public int deleteNotifications(Long userId) {
        String qs = "DELETE FROM TbNotification t WHERE t.userId = :userId AND t.queuedFlag = false";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        return q.executeUpdate();
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
        q.setParameter("now", Instant.now());
        List<Long> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
