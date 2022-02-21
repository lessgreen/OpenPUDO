package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.ExternalFileDao;
import less.green.openpudo.business.model.TbExternalFile;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.util.UUID;

@RequestScoped
@Transactional
@Log4j2
public class ExternalFileService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    StorageService storageService;

    @Inject
    ExternalFileDao externalFileDao;

    public Response getExternalFile(UUID externalFileId) {
        TbExternalFile ext = externalFileDao.get(externalFileId);
        if (ext == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        byte[] bytes;
        try {
            bytes = storageService.readFileBinary(externalFileId);
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }
        if (bytes == null) {
            log.error("[{}] External file {} exists in database but not on filesystem", context.getExecutionId(), externalFileId);
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        return Response.ok(bytes).header("Content-Type", ext.getMimeType()).build();
    }

}
