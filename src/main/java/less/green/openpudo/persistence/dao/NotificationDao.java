package less.green.openpudo.persistence.dao;

import java.util.Collections;
import java.util.Date;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import less.green.openpudo.persistence.model.TbNotification;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class NotificationDao extends BaseEntityDao<TbNotification, Long> {

    public NotificationDao() {
        super(TbNotification.class, "notificationId");
    }

    public List<TbNotification> getNotificationList(Long userId, int limit, int offset) {
        String qs = "SELECT t FROM TbNotification t WHERE t.userId = :userId ORDER BY t.createTms DESC";
        TypedQuery<TbNotification> q = em.createQuery(qs, TbNotification.class);
        q.setParameter("userId", userId);
        q.setMaxResults(limit);
        q.setFirstResult(offset);
        List<TbNotification> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

    public int markNotificationsAsRead(Long userId) {
        String qs = "UPDATE TbNotification t SET t.readTms = :now WHERE t.userId = :userId AND t.readTms IS NULL";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        q.setParameter("now", new Date());
        int cnt = q.executeUpdate();
        return cnt;
    }

}
