package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbRewardPolicy;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class RewardPolicyDao extends BaseEntityDao<TbRewardPolicy, Long> {

    public RewardPolicyDao() {
        super(TbRewardPolicy.class, "rewardPolicyId");
    }

    public TbRewardPolicy getActiveRewardPolicy(Long pudoId) {
        String qs = "SELECT t FROM TbRewardPolicy t WHERE t.pudoId = :pudoId AND t.deleteTms IS NULL";
        try {
            TypedQuery<TbRewardPolicy> q = em.createQuery(qs, TbRewardPolicy.class);
            q.setParameter("pudoId", pudoId);
            return q.getSingleResult();
        } catch (NoResultException ex) {
            return null;
        }
    }

}
