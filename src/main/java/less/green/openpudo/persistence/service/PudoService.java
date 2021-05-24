package less.green.openpudo.persistence.service;

import java.util.Date;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import static less.green.openpudo.common.StringUtils.sanitizeString;
import less.green.openpudo.persistence.dao.PudoDao;
import less.green.openpudo.persistence.dao.PudoUserRoleDao;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.rest.dto.pudo.Pudo;

@RequestScoped
@Transactional
public class PudoService {

    @Inject
    PudoDao pudoDao;
    @Inject
    PudoUserRoleDao pudoUserRoleDao;

    public TbPudo getPudoById(Long pudoId) {
        return pudoDao.get(pudoId);
    }

    public boolean isPudoOwner(Long userId) {
        return pudoUserRoleDao.isPudoOwner(userId);
    }

    public TbPudo getPudoByOwnerUserId(Long userId) {
        return pudoDao.getPudoByOwnerUserId(userId);
    }

    public TbPudo updatePudoByOwnerUserId(Long userId, Pudo req) {
        Date now = new Date();
        TbPudo pudo = getPudoByOwnerUserId(userId);
        pudo.setUpdateTms(now);
        pudo.setBusinessName(sanitizeString(req.getBusinessName()));
        pudo.setVat(sanitizeString(req.getVat()));
        pudo.setPhoneNumber(req.getPhoneNumber());
        pudo.setContactNotes(req.getContactNotes());
        pudoDao.flush();
        return pudo;
    }

}
