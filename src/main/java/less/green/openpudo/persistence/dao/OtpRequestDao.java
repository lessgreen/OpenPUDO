package less.green.openpudo.persistence.dao;

import less.green.openpudo.persistence.dao.usertype.OtpRequestType;
import less.green.openpudo.persistence.model.TbOtpRequest;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.UUID;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
public class OtpRequestDao extends BaseEntityDao<TbOtpRequest, UUID> {

    public OtpRequestDao() {
        super(TbOtpRequest.class, "requestId");
    }

    public TbOtpRequest getOtpRequestByUserIdAndRequestType(Long userId, OtpRequestType requestType) {
        String qs = "SELECT t FROM TbOtpRequest t WHERE t.userId = :userId AND t.requestType = :requestType";
        try {
            TypedQuery<TbOtpRequest> q = em.createQuery(qs, TbOtpRequest.class);
            q.setParameter("userId", userId);
            q.setParameter("requestType", requestType);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
