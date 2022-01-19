package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.cdi.service.StorageService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.tuple.Triplet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pudo.Pudo;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.Date;
import java.util.UUID;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class PudoService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    StorageService storageService;

    @Inject
    ExternalFileDao externalFileDao;
    @Inject
    PackageDao packageDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPudoRelationDao userPudoRelationDao;

    @Inject
    DtoMapper dtoMapper;

    public Pudo getPudo(Long pudoId) {
        Triplet<TbPudo, TbAddress, TbRating> rs = pudoDao.getPudoDeep(pudoId);
        if (rs == null) {
            return null;
        }
        Pudo ret = dtoMapper.mapPudoEntityToDto(rs);
        // TODO: reward message
        long customerCount = userPudoRelationDao.getActiveCustomerCountByPudoId(pudoId);
        ret.setCustomerCount(customerCount);
        long packageCount = packageDao.getPackageCountByPudoId(pudoId);
        ret.setPackageCount(packageCount);
        // customized address must be populated only if the caller is pudo customer
        if (context.getUserId() != null) {
            TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudoId, context.getUserId());
            if (userPudoRelation != null) {
                ret.setCustomizedAddress(createCustomizedAddress(rs.getValue0(), rs.getValue1(), userPudoRelation));
            }
        }
        return ret;
    }

    public Pudo getCurrentPudo() {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.PUDO) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
        return getPudo(pudoId);
    }

    private String createCustomizedAddress(TbPudo pudo, TbAddress address, TbUserPudoRelation userPudoRelation) {
        StringBuilder sb = new StringBuilder();
        // first line: pudo name and customer suffix
        sb.append(pudo.getBusinessName());
        sb.append(" ");
        sb.append(userPudoRelation.getCustomerSuffix());
        sb.append("\n");
        // second line: street and street number (if any)
        sb.append(address.getStreet());
        if (!isEmpty(address.getStreetNum())) {
            sb.append(" ");
            sb.append(address.getStreetNum());
            sb.append("\n");
        }
        // third line: zip code (if any), city and province
        if (!isEmpty(address.getZipCode())) {
            sb.append(address.getZipCode());
            sb.append(" ");
        }
        sb.append(address.getCity());
        sb.append(" (");
        sb.append(address.getProvince());
        sb.append(")");
        return sb.toString();
    }

    public UUID updateCurrentPudoPicture(String mimeType, byte[] bytes) {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.PUDO) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        Date now = new Date();
        Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
        TbPudo pudo = pudoDao.get(pudoId);
        UUID oldId = pudo.getPudoPicId();
        UUID newId = UUID.randomUUID();
        // save new file first
        storageService.saveFileBinary(newId, bytes);
        // delete old file if any
        if (oldId != null) {
            storageService.deleteFile(oldId);
        }
        // if everything is ok, we can update database
        // save new row
        TbExternalFile ent = new TbExternalFile();
        ent.setExternalFileId(newId);
        ent.setCreateTms(now);
        ent.setMimeType(mimeType);
        externalFileDao.persist(ent);
        externalFileDao.flush();
        // switch foreign key
        pudo.setUpdateTms(now);
        pudo.setPudoPicId(newId);
        pudoDao.flush();
        // remove old row
        externalFileDao.delete(oldId);
        externalFileDao.flush();
        log.info("[{}] Updated profile picture for pudo: {}", context.getExecutionId(), pudo.getPudoId());
        return newId;
    }

}
