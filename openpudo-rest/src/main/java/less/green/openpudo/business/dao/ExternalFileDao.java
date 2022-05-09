package less.green.openpudo.business.dao;

import less.green.openpudo.business.model.TbExternalFile;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

@RequestScoped
@Transactional(Transactional.TxType.MANDATORY)
@Log4j2
public class ExternalFileDao extends BaseEntityDao<TbExternalFile, UUID> {

    public ExternalFileDao() {
        super(TbExternalFile.class, "externalFileId");
    }

    public Set<String> getAllStoredFiles() {
        String qs = "SELECT t.externalFileId FROM TbExternalFile t";
        TypedQuery<UUID> q = em.createQuery(qs, UUID.class);
        List<UUID> rs = q.getResultList();
        return rs.isEmpty() ? Collections.emptySet() : rs.stream().map(UUID::toString).collect(Collectors.toSet());
    }

}
