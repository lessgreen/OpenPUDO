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
import less.green.openpudo.rest.dto.pudo.reward.*;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import static less.green.openpudo.common.StringUtils.isEmpty;
import static less.green.openpudo.common.StringUtils.sanitizeString;

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
        // customized address must be populated only if the caller is a pudo customer
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

    public List<RewardOption> getRewardSchema() {
        List<RewardOption> ret = new ArrayList<>(5);
        // free for all
        RewardOption free = new RewardOption();
        ret.add(free);
        free.setName("free");
        free.setText(localizationService.getMessage(context.getLanguage(), "label.reward.free"));
        free.setExclusive(true);
        free.setExtraInfo(null);
        // customers
        RewardOption customers = new RewardOption();
        ret.add(customers);
        customers.setName("customers");
        customers.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers"));
        customers.setExclusive(false);
        ExtraInfoSelect customersExtraInfo = new ExtraInfoSelect();
        customers.setExtraInfo(customersExtraInfo);
        customersExtraInfo.setName("customers.select");
        customersExtraInfo.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select"));
        customersExtraInfo.setType(ExtraInfoType.SELECT);
        customersExtraInfo.setMandatoryValue(true);
        List<ExtraInfoSelectItem> selectItems = new ArrayList<>();
        customersExtraInfo.setSelectItems(selectItems);
        ExtraInfoSelectItem select1Day = new ExtraInfoSelectItem();
        selectItems.add(select1Day);
        select1Day.setName("1/day");
        select1Day.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/day"));
        select1Day.setExtraInfo(null);
        ExtraInfoSelectItem select3Week = new ExtraInfoSelectItem();
        selectItems.add(select3Week);
        select3Week.setName("3/week");
        select3Week.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.3/week"));
        select3Week.setExtraInfo(null);
        ExtraInfoSelectItem select1Week = new ExtraInfoSelectItem();
        selectItems.add(select1Week);
        select1Week.setName("1/week");
        select1Week.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/week"));
        select1Week.setExtraInfo(null);
        ExtraInfoSelectItem select2Month = new ExtraInfoSelectItem();
        selectItems.add(select2Month);
        select2Month.setName("2/month");
        select2Month.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.2/month"));
        select2Month.setExtraInfo(null);
        ExtraInfoSelectItem select1Month = new ExtraInfoSelectItem();
        selectItems.add(select1Month);
        select1Month.setName("1/month");
        select1Month.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/month"));
        select1Month.setExtraInfo(null);
        ExtraInfoSelectItem select4Year = new ExtraInfoSelectItem();
        selectItems.add(select4Year);
        select4Year.setName("4/year");
        select4Year.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.4/year"));
        select4Year.setExtraInfo(null);
        ExtraInfoSelectItem select2Year = new ExtraInfoSelectItem();
        selectItems.add(select2Year);
        select2Year.setName("2/year");
        select2Year.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.2/year"));
        select2Year.setExtraInfo(null);
        ExtraInfoSelectItem select1Year = new ExtraInfoSelectItem();
        selectItems.add(select1Year);
        select1Year.setName("1/year");
        select1Year.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/year"));
        select1Year.setExtraInfo(null);
        ExtraInfoSelectItem other = new ExtraInfoSelectItem();
        selectItems.add(other);
        other.setName("other");
        other.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.other"));
        ExtraInfoText otherExtraInfo = new ExtraInfoText();
        other.setExtraInfo(otherExtraInfo);
        otherExtraInfo.setType(ExtraInfoType.TEXT);
        otherExtraInfo.setMandatoryValue(true);
        otherExtraInfo.setName("customers.select.other.text");
        otherExtraInfo.setText(localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.other.text"));
        // members
        RewardOption members = new RewardOption();
        ret.add(members);
        members.setName("members");
        members.setText(localizationService.getMessage(context.getLanguage(), "label.reward.members"));
        members.setExclusive(false);
        ExtraInfoText membersExtraInfo = new ExtraInfoText();
        members.setExtraInfo(membersExtraInfo);
        membersExtraInfo.setName("members.text");
        membersExtraInfo.setText(localizationService.getMessage(context.getLanguage(), "label.reward.members.text"));
        membersExtraInfo.setType(ExtraInfoType.TEXT);
        membersExtraInfo.setMandatoryValue(false);
        // buy
        RewardOption buy = new RewardOption();
        ret.add(buy);
        buy.setName("buy");
        buy.setText(localizationService.getMessage(context.getLanguage(), "label.reward.buy"));
        buy.setExclusive(false);
        ExtraInfoText buyExtraInfo = new ExtraInfoText();
        buy.setExtraInfo(buyExtraInfo);
        buyExtraInfo.setName("buy.text");
        buyExtraInfo.setText(localizationService.getMessage(context.getLanguage(), "label.reward.buy.text"));
        buyExtraInfo.setType(ExtraInfoType.TEXT);
        buyExtraInfo.setMandatoryValue(false);
        // fee
        RewardOption fee = new RewardOption();
        ret.add(fee);
        fee.setName("fee");
        fee.setText(localizationService.getMessage(context.getLanguage(), "label.reward.fee"));
        fee.setExclusive(false);
        ExtraInfoDecimal feeExtraInfo = new ExtraInfoDecimal();
        fee.setExtraInfo(feeExtraInfo);
        feeExtraInfo.setName("fee.price");
        feeExtraInfo.setText(localizationService.getMessage(context.getLanguage(), "label.reward.fee.price"));
        feeExtraInfo.setType(ExtraInfoType.DECIMAL);
        feeExtraInfo.setMandatoryValue(true);
        feeExtraInfo.setMin(BigDecimal.valueOf(0.1));
        feeExtraInfo.setMax(BigDecimal.valueOf(2.0));
        feeExtraInfo.setScale(2);
        feeExtraInfo.setStep(BigDecimal.valueOf(0.1));
        return ret;
    }

    public TbRewardPolicy mapRewardPolicyDtoToEntity(List<RewardOption> rewardPolicy) {
        if (rewardPolicy.size() != 5) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
        }
        // preliminary check that all RewardOption have mandatory fields populated, will relax checks afterwards
        for (var opt : rewardPolicy) {
            if (isEmpty(opt.getName())) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            if (opt.getChecked() == null) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
        }

        TbRewardPolicy ret = new TbRewardPolicy();
        RewardOption free = rewardPolicy.stream().filter(i -> i.getName().equals("free")).findFirst().orElseThrow(() -> new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy")));
        RewardOption customers = rewardPolicy.stream().filter(i -> i.getName().equals("customers")).findFirst().orElseThrow(() -> new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy")));
        RewardOption members = rewardPolicy.stream().filter(i -> i.getName().equals("members")).findFirst().orElseThrow(() -> new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy")));
        RewardOption buy = rewardPolicy.stream().filter(i -> i.getName().equals("buy")).findFirst().orElseThrow(() -> new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy")));
        RewardOption fee = rewardPolicy.stream().filter(i -> i.getName().equals("fee")).findFirst().orElseThrow(() -> new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy")));

        // some quantity checks
        if (free.getChecked() && rewardPolicy.stream().filter(i -> i.getChecked()).count() > 1) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
        }
        if (rewardPolicy.stream().noneMatch(i -> i.getChecked())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
        }

        // free
        if (free.getChecked()) {
            ret.setFreeChecked(true);
        } else {
            ret.setFreeChecked(false);
        }

        // customers
        if (customers.getChecked()) {
            ret.setCustomerChecked(true);
        } else {
            ret.setCustomerChecked(false);
        }
        if (customers.getChecked()) {
            if (customers.getExtraInfo() == null || !(customers.getExtraInfo() instanceof ExtraInfoSelect)) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoSelect customersExtraInfo = (ExtraInfoSelect) customers.getExtraInfo();
            if (!customersExtraInfo.getName().equals("customers.select") || customersExtraInfo.getValue() == null) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoSelectItem customersExtraInfoValue = customersExtraInfo.getValue();
            if (!customersExtraInfoValue.getName().equals("1/day")
                    && !customersExtraInfoValue.getName().equals("3/week")
                    && !customersExtraInfoValue.getName().equals("1/week")
                    && !customersExtraInfoValue.getName().equals("2/month")
                    && !customersExtraInfoValue.getName().equals("1/month")
                    && !customersExtraInfoValue.getName().equals("4/year")
                    && !customersExtraInfoValue.getName().equals("2/year")
                    && !customersExtraInfoValue.getName().equals("1/year")
                    && !customersExtraInfoValue.getName().equals("other")) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ret.setCustomerSelectitem(customersExtraInfoValue.getName());
            if (customersExtraInfoValue.getName().equals("other")) {
                if (customersExtraInfoValue.getExtraInfo() == null || !(customersExtraInfoValue.getExtraInfo() instanceof ExtraInfoText)) {
                    throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
                }
                ExtraInfoText otherExtraInfo = (ExtraInfoText) customersExtraInfoValue.getExtraInfo();
                if (!otherExtraInfo.getName().equals("customers.select.other.text") || isEmpty(otherExtraInfo.getValue())) {
                    throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
                }
                ret.setCustomerSelectitemText(sanitizeString(otherExtraInfo.getValue()));
            }
        }

        // members
        if (members.getChecked()) {
            ret.setMembersChecked(true);
        } else {
            ret.setMembersChecked(false);
        }
        if (members.getChecked()) {
            if (members.getExtraInfo() == null || !(members.getExtraInfo() instanceof ExtraInfoText)) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoText membersExtraInfo = (ExtraInfoText) members.getExtraInfo();
            if (!membersExtraInfo.getName().equals("members.text")) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ret.setMembersText(sanitizeString(membersExtraInfo.getValue()));
        }

        // buy
        if (buy.getChecked()) {
            ret.setBuyChecked(true);
        } else {
            ret.setBuyChecked(false);
        }
        if (buy.getChecked()) {
            if (buy.getExtraInfo() == null || !(buy.getExtraInfo() instanceof ExtraInfoText)) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoText buyExtraInfo = (ExtraInfoText) buy.getExtraInfo();
            if (!buyExtraInfo.getName().equals("buy.text")) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ret.setBuyText(sanitizeString(buyExtraInfo.getValue()));
        }

        // fee
        if (fee.getChecked()) {
            ret.setFeeChecked(true);
        } else {
            ret.setFeeChecked(false);
        }
        if (fee.getChecked()) {
            if (fee.getExtraInfo() == null || !(fee.getExtraInfo() instanceof ExtraInfoDecimal)) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoDecimal feeExtraInfo = (ExtraInfoDecimal) fee.getExtraInfo();
            if (!feeExtraInfo.getName().equals("fee.price") || feeExtraInfo.getValue() == null) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            if (feeExtraInfo.getValue().compareTo(BigDecimal.valueOf(0.1)) < 0 || feeExtraInfo.getValue().compareTo(BigDecimal.valueOf(2.0)) > 0 || feeExtraInfo.getValue().scale() > 2) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            // check if value is multiple of step
            try {
                feeExtraInfo.getValue().divide(BigDecimal.valueOf(0.1), 0, RoundingMode.UNNECESSARY);
            } catch (ArithmeticException ex) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ret.setFeePrice(feeExtraInfo.getValue());
        }

        return ret;
    }

}
