package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbUser;
import less.green.openpudo.common.dto.tuple.Pair;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class UserDao extends BaseEntityDao<TbUser, Long> {

    public UserDao() {
        super(TbUser.class, "userId");
    }

    public TbUser getUserByPhoneNumber(String phoneNumber) {
        String qs = "SELECT t FROM TbUser t WHERE t.phoneNumber = :phoneNumber";
        try {
            TypedQuery<TbUser> q = em.createQuery(qs, TbUser.class);
            q.setParameter("phoneNumber", phoneNumber);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

    public List<Pair<String, Integer>> deleteUser(Long userId, Long pudoId) {
        List<Pair<String, Integer>> ret = new ArrayList<>();
        String qs = "DELETE FROM TbDeviceToken t WHERE t.userId = :userId";
        Query q = em.createQuery(qs);
        q.setParameter("userId", userId);
        int cnt = q.executeUpdate();
        ret.add(new Pair<>("TbDeviceToken", cnt));

        qs = "DELETE FROM TbOtpRequest t WHERE t.userId = :userId";
        q = em.createQuery(qs);
        q.setParameter("userId", userId);
        cnt = q.executeUpdate();
        ret.add(new Pair<>("TbOtpRequest", cnt));

        qs = "DELETE FROM TbNotification t WHERE t.userId = :userId";
        q = em.createQuery(qs);
        q.setParameter("userId", userId);
        cnt = q.executeUpdate();
        // delete favourite notifications that may have survived from first pass
        if (pudoId == null) {
            qs = "DELETE FROM TbNotificationFavourite t WHERE t.customerUserId = :userId";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
        } else {
            qs = "DELETE FROM TbNotificationFavourite t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
        }
        cnt += q.executeUpdate();
        // delete package notifications that may have survived from first pass
        if (pudoId == null) {
            qs = "DELETE FROM TbNotificationPackage t1 WHERE t1.packageId IN (SELECT t2 FROM TbPackage t2 WHERE t2.userId = :userId)";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
        } else {
            qs = "DELETE FROM TbNotificationPackage t1 WHERE t1.packageId IN (SELECT t2 FROM TbPackage t2 WHERE t2.pudoId = :pudoId)";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
        }
        cnt += q.executeUpdate();
        ret.add(new Pair<>("TbNotification", cnt));

        if (pudoId == null) {
            qs = "DELETE FROM TbPackageEvent t1 WHERE t1.packageId IN (SELECT t2 FROM TbPackage t2 WHERE t2.userId = :userId)";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
        } else {
            qs = "DELETE FROM TbPackageEvent t1 WHERE t1.packageId IN (SELECT t2 FROM TbPackage t2 WHERE t2.pudoId = :pudoId)";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
        }
        cnt = q.executeUpdate();
        ret.add(new Pair<>("TbPackageEvent", cnt));

        if (pudoId == null) {
            qs = "DELETE FROM TbPackage t WHERE t.userId = :userId";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
        } else {
            qs = "DELETE FROM TbPackage t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
        }
        cnt = q.executeUpdate();
        ret.add(new Pair<>("TbPackage", cnt));

        // delete by userId must be done anyway to delete the owner relationship if we are deleting a pudo
        if (pudoId == null) {
            qs = "DELETE FROM TbUserPudoRelation t WHERE t.userId = :userId";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
        } else {
            qs = "DELETE FROM TbUserPudoRelation t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
        }
        cnt = q.executeUpdate();
        ret.add(new Pair<>("TbUserPudoRelation", cnt));

        if (pudoId == null) {
            qs = "DELETE FROM TbUserPreferences t WHERE t.userId = :userId";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbUserPreferences", cnt));

            qs = "DELETE FROM TbUserProfile t WHERE t.userId = :userId";
            q = em.createQuery(qs);
            q.setParameter("userId", userId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbUserProfile", cnt));
        } else {
            qs = "DELETE FROM TbRating t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbRating", cnt));

            qs = "DELETE FROM TbRewardPolicy t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbRewardPolicy", cnt));

            qs = "DELETE FROM TbAddress t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbAddress", cnt));

            qs = "DELETE FROM TbPudo t WHERE t.pudoId = :pudoId";
            q = em.createQuery(qs);
            q.setParameter("pudoId", pudoId);
            cnt = q.executeUpdate();
            ret.add(new Pair<>("TbPudo", cnt));
        }

        qs = "DELETE FROM TbUser t WHERE t.userId = :userId";
        q = em.createQuery(qs);
        q.setParameter("userId", userId);
        cnt = q.executeUpdate();
        ret.add(new Pair<>("TbUser", cnt));

        return ret;
    }

}
