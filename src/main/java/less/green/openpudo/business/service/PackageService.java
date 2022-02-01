package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.PackageDao;
import less.green.openpudo.business.dao.PackageEventDao;
import less.green.openpudo.business.dao.UserDao;
import less.green.openpudo.business.dao.UserPudoRelationDao;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.PackageStatus;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.common.dto.tuple.Septet;
import less.green.openpudo.common.dto.tuple.Sextet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageSummary;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class PackageService {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    CryptoService cryptoService;

    @Inject
    PudoService pudoService;

    @Inject
    PackageDao packageDao;
    @Inject
    PackageEventDao packageEventDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPudoRelationDao userPudoRelationDao;

    @Inject
    DtoMapper dtoMapper;

    public Package getPackage(Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            return null;
        }
        // operation is allowed if the current user is the package pudo owner or the package recipient
        TbUser caller = userDao.get(context.getUserId());
        if (caller.getAccountType() == AccountType.CUSTOMER) {
            if (!rs.getValue0().getUserId().equals(context.getUserId())) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
        } else if (caller.getAccountType() == AccountType.PUDO) {
            Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
            if (!rs.getValue0().getPudoId().equals(pudoId)) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
            }
        } else {
            throw new AssertionError("Unsupported AccountType: " + caller.getAccountType());
        }
        return dtoMapper.mapPackageEntityToDto(rs);
    }

    protected List<PackageSummary> getPackages(AccountType accountType, Long referenceId, boolean history, int limit, int offset) {
        List<PackageStatus> packageStatuses;
        if (accountType == AccountType.CUSTOMER) {
            packageStatuses = history ? null : Arrays.asList(PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED, PackageStatus.COLLECTED);
        } else if (accountType == AccountType.PUDO) {
            packageStatuses = history ? null : Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFY_SENT, PackageStatus.NOTIFIED);
        } else {
            throw new AssertionError("Unsupported AccountType: " + accountType);
        }
        List<Sextet<TbPackage, TbPackageEvent, TbPudo, TbAddress, TbUserProfile, TbUserPudoRelation>> rs = packageDao.getPackages(accountType, referenceId, packageStatuses, history, limit, offset);
        List<PackageSummary> ret = new ArrayList<>(rs.size());
        for (var row : rs) {
            ret.add(dtoMapper.mapProjectionToPackageSummary(new Septet<>(row.getValue0(), row.getValue1(), row.getValue2(), row.getValue3(), row.getValue4(), row.getValue5(), cryptoService.hashidEncode(row.getValue0().getPackageId()))));
        }
        return ret;
    }

    public Package deliveredPackage(DeliveredPackageRequest req) {
        // operation is allowed if the current user is a pudo owner
        Long pudoId = pudoService.getCurrentPudoId();
        // and if there is a customer relationship with user
        TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveCustomerRelation(pudoId, req.getUserId());
        if (userPudoRelation == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.forbidden"));
        }

        Date now = new Date();
        TbPackage pack = new TbPackage();
        pack.setCreateTms(now);
        pack.setUpdateTms(now);
        pack.setPudoId(pudoId);
        pack.setUserId(req.getUserId());
        pack.setPackagePicId(null);
        packageDao.persist(pack);
        packageDao.flush();
        TbPackageEvent event = new TbPackageEvent();
        event.setPackageId(pack.getPackageId());
        event.setCreateTms(now);
        event.setPackageStatus(PackageStatus.DELIVERED);
        event.setAutoFlag(false);
        event.setNotes(sanitizeString(req.getNotes()));
        packageEventDao.persist(event);
        packageEventDao.flush();
        return getPackage(pack.getPackageId());
    }


}
