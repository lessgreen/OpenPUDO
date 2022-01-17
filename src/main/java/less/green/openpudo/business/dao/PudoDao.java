package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbPudo;
import less.green.openpudo.rest.dto.map.PudoMarker;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class PudoDao extends BaseEntityDao<TbPudo, Long> {

    public PudoDao() {
        super(TbPudo.class, "pudoId");
    }

    public List<PudoMarker> getPudosOnMap(BigDecimal latMin, BigDecimal latMax, BigDecimal lonMin, BigDecimal lonMax) {
        String qs = "SELECT new less.green.openpudo.rest.dto.map.PudoMarker(t1.pudoId, t1.businessName, t2.lat, t2.lon) "
                + "FROM TbPudo t1, TbAddress t2 "
                + "WHERE t1.pudoId = t2.pudoId "
                + "AND t2.lat >= :latMin AND t2.lat <= :latMax "
                + "AND t2.lon >= :lonMin AND t2.lon <= :lonMax";
        TypedQuery<PudoMarker> q = em.createQuery(qs, PudoMarker.class);
        q.setParameter("latMin", latMin);
        q.setParameter("latMax", latMax);
        q.setParameter("lonMin", lonMin);
        q.setParameter("lonMax", lonMax);
        List<PudoMarker> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptyList() : rs;
    }

}
