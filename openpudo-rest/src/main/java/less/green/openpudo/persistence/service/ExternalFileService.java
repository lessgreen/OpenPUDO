package less.green.openpudo.persistence.service;

import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.ExternalFileDao;
import less.green.openpudo.persistence.model.TbExternalFile;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.UUID;

@RequestScoped
@Transactional
@Log4j2
public class ExternalFileService {

    @Inject
    StorageService storageService;

    @Inject
    ExternalFileDao externalFileDao;

    public Pair<TbExternalFile, byte[]> getExternalFile(UUID externalFileId) {
        TbExternalFile ext = externalFileDao.get(externalFileId);
        if (ext == null) {
            return null;
        }
        byte[] bytes = storageService.readFileBinary(externalFileId);
        if (bytes == null) {
            log.error("External file {} exists in database but not on filesystem", externalFileId);
            return null;
        }
        return new Pair<>(ext, bytes);
    }

}
