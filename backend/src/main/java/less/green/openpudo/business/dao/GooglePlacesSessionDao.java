package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbGooglePlacesSession;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.time.Instant;
import java.util.UUID;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class GooglePlacesSessionDao extends BaseEntityDao<TbGooglePlacesSession, UUID> {

    public GooglePlacesSessionDao() {
        super(TbGooglePlacesSession.class, "sessionId");
    }

    public TbGooglePlacesSession getSessionByUserId(Long userId) {
        String qs = "SELECT t FROM TbGooglePlacesSession t WHERE t.userId = :userId";
        try {
            TypedQuery<TbGooglePlacesSession> q = em.createQuery(qs, TbGooglePlacesSession.class);
            q.setParameter("userId", userId);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public TbGooglePlacesSession getSessionByPhoneNumber(String phoneNumber) {
        String qs = "SELECT t FROM TbGooglePlacesSession t WHERE t.phoneNumber = :phoneNumber";
        try {
            TypedQuery<TbGooglePlacesSession> q = em.createQuery(qs, TbGooglePlacesSession.class);
            q.setParameter("phoneNumber", phoneNumber);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public int removeExpiredGooglePlacesSessions(Instant timeThreshold) {
        String qs = "DELETE FROM TbGooglePlacesSession t WHERE t.updateTms < :timeThreshold";
        Query q = em.createQuery(qs);
        q.setParameter("timeThreshold", timeThreshold);
        return q.executeUpdate();
    }

}
