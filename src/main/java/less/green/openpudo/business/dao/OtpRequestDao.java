package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbOtpRequest;
import less.green.openpudo.business.model.usertype.OtpRequestType;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.UUID;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class OtpRequestDao extends BaseEntityDao<TbOtpRequest, UUID> {

    public OtpRequestDao() {
        super(TbOtpRequest.class, "requestId");
    }

    public TbOtpRequest getOtpRequestByUserId(Long userId, OtpRequestType requestType) {
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

    public TbOtpRequest getOtpRequestByPhoneNumber(String phoneNumber, OtpRequestType requestType) {
        String qs = "SELECT t FROM TbOtpRequest t WHERE t.phoneNumber = :phoneNumber AND t.requestType = :requestType";
        try {
            TypedQuery<TbOtpRequest> q = em.createQuery(qs, TbOtpRequest.class);
            q.setParameter("phoneNumber", phoneNumber);
            q.setParameter("requestType", requestType);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
