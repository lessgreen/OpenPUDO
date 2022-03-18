package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.DeletedUserDataDao;
import less.green.openpudo.business.dao.ExternalFileDao;
import less.green.openpudo.business.model.TbDeletedUserData;
import less.green.openpudo.business.model.TbExternalFile;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;
import net.coobird.thumbnailator.Thumbnails;

import javax.enterprise.context.RequestScoped;
import javax.imageio.ImageIO;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Date;
import java.util.UUID;

import static less.green.openpudo.common.FormatUtils.smartElapsed;
import static less.green.openpudo.common.MultipartUtils.PART_NAME;

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
    DeletedUserDataDao deletedUserDataDao;
    @Inject
    ExternalFileDao externalFileDao;

    public Response getExternalFile(UUID externalFileId) {
        TbExternalFile externalFile = externalFileDao.get(externalFileId);
        if (externalFile == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        byte[] bytes;
        try {
            bytes = storageService.readFileBinary(externalFileId);
        } catch (RuntimeException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }
        if (bytes == null) {
            log.error("[{}] External file {} exists in database but not on filesystem", context.getExecutionId(), externalFileId);
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        return Response.ok(bytes).header("Content-Type", externalFile.getMimeType()).build();
    }

    public Response getDeletedUserData(UUID userDataId) {
        TbDeletedUserData deletedUserData = deletedUserDataDao.get(userDataId);
        if (deletedUserData == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        return Response.ok(deletedUserData.getUserData()).header("Content-Type", "text/plain").build();
    }

    protected TbExternalFile saveExternalImage(byte[] bytes) {
        // read byte array as image
        BufferedImage original;
        try {
            original = ImageIO.read(new ByteArrayInputStream(bytes));
        } catch (IOException ex) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", PART_NAME));
        }
        // resize and recompress image
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try {
            long startTime = System.nanoTime();
            if (original.getWidth() >= 1200) {
                Thumbnails.of(original).width(1200).outputFormat("jpg").outputQuality(0.6).toOutputStream(baos);
            } else {
                Thumbnails.of(original).width(original.getWidth()).outputFormat("jpg").outputQuality(0.6).toOutputStream(baos);
            }
            long endTime = System.nanoTime();
            log.info("[{}] Image compressed to {}% of original size in {}", context.getExecutionId(),
                    BigDecimal.valueOf(((long) baos.size()) * 100L).divide(BigDecimal.valueOf(bytes.length), 0, RoundingMode.HALF_UP), smartElapsed(endTime - startTime));
        } catch (IOException ex) {
            throw new RuntimeException("Error while resizing image", ex);
        }
        // save it to storage area
        UUID newId = UUID.randomUUID();
        storageService.saveFileBinary(newId, baos.toByteArray());
        // persist entity
        TbExternalFile ret = new TbExternalFile();
        ret.setExternalFileId(newId);
        ret.setCreateTms(new Date());
        ret.setMimeType("image/jpeg");
        externalFileDao.persist(ret);
        externalFileDao.flush();
        return ret;
    }

    public void deleteExternalFile(UUID externalFileId) {
        storageService.deleteFile(externalFileId);
        externalFileDao.delete(externalFileId);
        externalFileDao.flush();
    }

}
