package less.green.openpudo.business.service;

import less.green.openpudo.business.dao.*;
import less.green.openpudo.business.model.*;
import less.green.openpudo.business.model.usertype.AccountType;
import less.green.openpudo.business.model.usertype.RelationType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.common.dto.tuple.Quintet;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pack.PackageSummary;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.UpdatePudoRequest;
import less.green.openpudo.rest.dto.pudo.reward.*;
import less.green.openpudo.rest.dto.user.UserSummary;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.transaction.Transactional;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.*;
import java.util.stream.Collectors;

import static less.green.openpudo.common.FormatUtils.calcSavedCO2;
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
    ExternalFileService externalFileService;
    @Inject
    PackageService packageService;

    @Inject
    AddressDao addressDao;
    @Inject
    PackageDao packageDao;
    @Inject
    PudoDao pudoDao;
    @Inject
    RewardPolicyDao rewardPolicyDao;
    @Inject
    UserDao userDao;
    @Inject
    UserPudoRelationDao userPudoRelationDao;

    @Inject
    DtoMapper dtoMapper;

    public Pudo getPudo(Long pudoId) {
        Quartet<TbPudo, TbAddress, TbRating, TbRewardPolicy> rs = pudoDao.getPudo(pudoId);
        if (rs == null) {
            return null;
        }
        String rewardMessage = createPolicyMessage(rs.getValue3());
        long customerCount = userPudoRelationDao.getActiveCustomerCountByPudoId(pudoId);
        long packageCount = packageDao.getPackageCountByPudoId(pudoId);
        String savedCO2 = calcSavedCO2(packageCount);
        String customizedAddress = null;
        // customized address must be populated only if the caller is a pudo customer, of if it is the pudo owner (with a fake example suffix)
        if (context.getUserId() != null) {
            TbUserPudoRelation userPudoRelation = userPudoRelationDao.getUserPudoActiveRelation(pudoId, context.getUserId());
            if (userPudoRelation != null && userPudoRelation.getRelationType() == RelationType.CUSTOMER) {
                customizedAddress = createCustomizedAddress(rs.getValue0(), rs.getValue1(), userPudoRelation.getCustomerSuffix());
            } else if (userPudoRelation != null && userPudoRelation.getRelationType() == RelationType.OWNER) {
                customizedAddress = createCustomizedAddress(rs.getValue0(), rs.getValue1(), "AB123");
            }
        }
        Pudo ret = dtoMapper.mapPudoDto(rs.getValue0(), rs.getValue1(), rs.getValue2(), rewardMessage, customerCount, packageCount, savedCO2, customizedAddress);
        // pudo email, if any, must be visible only to pudo owner
        if (context.getUserId() == null) {
            ret.setEmail(null);
        } else {
            TbUser caller = userDao.get(context.getUserId());
            if (caller.getAccountType() == AccountType.CUSTOMER || !getCurrentPudoId().equals(pudoId)) {
                ret.setEmail(null);
            }
        }
        return ret;
    }

    public Pudo getCurrentPudo() {
        Long pudoId = getCurrentPudoId();
        return getPudo(pudoId);
    }

    public Pudo updateCurrentPudo(UpdatePudoRequest req) {
        Long pudoId = getCurrentPudoId();
        Instant now = Instant.now();
        // we could update pudo, address, or both
        if (req.getPudo() != null) {
            TbPudo pudo = pudoDao.get(pudoId);
            pudo.setUpdateTms(now);
            pudo.setBusinessName(sanitizeString(req.getPudo().getBusinessName()));
            pudo.setPublicPhoneNumber(sanitizeString(req.getPudo().getPublicPhoneNumber()));
            pudo.setEmail(sanitizeString((req.getPudo().getEmail())));
            pudoDao.flush();
        }
        if (req.getAddressMarker() != null) {
            TbAddress oldAddress = addressDao.get(pudoId);
            TbAddress newAddress = dtoMapper.mapAddressEntity(req.getAddressMarker().getAddress());
            newAddress.setPudoId(oldAddress.getPudoId());
            newAddress.setCreateTms(oldAddress.getCreateTms());
            newAddress.setUpdateTms(now);
            addressDao.merge(newAddress);
            addressDao.flush();
        }
        log.info("[{}] Updated profile for PUDO: {}", context.getExecutionId(), pudoId);
        return getCurrentPudo();
    }

    public UUID updateCurrentPudoPicture(byte[] bytes) {
        Long pudoId = getCurrentPudoId();
        TbPudo pudo = pudoDao.get(pudoId);

        TbExternalFile externalFile = externalFileService.saveExternalImage(bytes);
        UUID oldId = pudo.getPudoPicId();
        UUID newId = externalFile.getExternalFileId();
        // switch foreign key
        pudo.setUpdateTms(externalFile.getCreateTms());
        pudo.setPudoPicId(externalFile.getExternalFileId());
        if (oldId != null) {
            externalFileService.deleteExternalFile(oldId);
        }
        log.info("[{}] Updated profile picture for PUDO: {}", context.getExecutionId(), pudoId);
        return newId;
    }

    public List<RewardOption> getRewardSchema() {
        List<RewardOption> ret = new ArrayList<>(5);

        // free for all
        RewardOption free = new RewardOption("free", localizationService.getMessage(context.getLanguage(), "label.reward.free"), RewardIcon.SMILE, true, false, null);
        ret.add(free);

        // customers
        RewardOption customers = new RewardOption("customers", localizationService.getMessage(context.getLanguage(), "label.reward.customers"), RewardIcon.SMILE, false, false);
        ret.add(customers);
        ExtraInfoSelect customersExtraInfo = new ExtraInfoSelect("customers.select", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select"), ExtraInfoType.SELECT, true, new ArrayList<>(9));
        customers.setExtraInfo(customersExtraInfo);
        // customers selectitems
        List<ExtraInfoSelectItem> values = customersExtraInfo.getValues();
        ExtraInfoSelectItem select1Day = new ExtraInfoSelectItem("customers.select.1/day", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/day"), false, null);
        values.add(select1Day);
        ExtraInfoSelectItem select3Week = new ExtraInfoSelectItem("customers.select.3/week", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.3/week"), false, null);
        values.add(select3Week);
        ExtraInfoSelectItem select1Week = new ExtraInfoSelectItem("customers.select.1/week", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/week"), false, null);
        values.add(select1Week);
        ExtraInfoSelectItem select2Month = new ExtraInfoSelectItem("customers.select.2/month", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.2/month"), false, null);
        values.add(select2Month);
        ExtraInfoSelectItem select1Month = new ExtraInfoSelectItem("customers.select.1/month", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/month"), false, null);
        values.add(select1Month);
        ExtraInfoSelectItem select4Year = new ExtraInfoSelectItem("customers.select.4/year", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.4/year"), false, null);
        values.add(select4Year);
        ExtraInfoSelectItem select2Year = new ExtraInfoSelectItem("customers.select.2/year", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.2/year"), false, null);
        values.add(select2Year);
        ExtraInfoSelectItem select1Year = new ExtraInfoSelectItem("customers.select.1/year", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.1/year"), false, null);
        values.add(select1Year);
        ExtraInfoSelectItem other = new ExtraInfoSelectItem("customers.select.other", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.other"), false);
        values.add(other);
        ExtraInfoText otherExtraInfo = new ExtraInfoText("customers.select.other.text", localizationService.getMessage(context.getLanguage(), "label.reward.customers.select.other.text"), ExtraInfoType.TEXT, true, null);
        other.setExtraInfo(otherExtraInfo);

        // members
        RewardOption members = new RewardOption("members", localizationService.getMessage(context.getLanguage(), "label.reward.members"), RewardIcon.CARD, false, false);
        ret.add(members);
        ExtraInfoText membersExtraInfo = new ExtraInfoText("members.text", localizationService.getMessage(context.getLanguage(), "label.reward.members.text"), ExtraInfoType.TEXT, false, null);
        members.setExtraInfo(membersExtraInfo);

        // buy
        RewardOption buy = new RewardOption("buy", localizationService.getMessage(context.getLanguage(), "label.reward.buy"), RewardIcon.BAG, false, false);
        ret.add(buy);
        ExtraInfoText buyExtraInfo = new ExtraInfoText("buy.text", localizationService.getMessage(context.getLanguage(), "label.reward.buy.text"), ExtraInfoType.TEXT, false, null);
        buy.setExtraInfo(buyExtraInfo);

        // fee
        RewardOption fee = new RewardOption("fee", localizationService.getMessage(context.getLanguage(), "label.reward.fee"), RewardIcon.MONEY, false, false);
        ret.add(fee);
        ExtraInfoDecimal feeExtraInfo = new ExtraInfoDecimal("fee.price", localizationService.getMessage(context.getLanguage(), "label.reward.fee.price"), ExtraInfoType.DECIMAL, true,
                BigDecimal.valueOf(0.1), BigDecimal.valueOf(2.0), 2, BigDecimal.valueOf(0.1), null);
        fee.setExtraInfo(feeExtraInfo);

        return ret;
    }

    public List<RewardOption> getCurrentPudoRewardPolicy() {
        Long pudoId = getCurrentPudoId();
        TbRewardPolicy rewardPolicy = rewardPolicyDao.getActiveRewardPolicy(pudoId);
        List<RewardOption> ret = getRewardSchema();

        // free for all
        if (rewardPolicy.getFreeChecked()) {
            RewardOption opt = ret.stream().filter(i -> i.getName().equals("free")).findAny().get();
            opt.setChecked(true);
        }

        // customers
        if (rewardPolicy.getCustomerChecked()) {
            RewardOption opt = ret.stream().filter(i -> i.getName().equals("customers")).findFirst().get();
            opt.setChecked(true);
            List<ExtraInfoSelectItem> values = ((ExtraInfoSelect) opt.getExtraInfo()).getValues();
            ExtraInfoSelectItem selectedValue = values.stream().filter(i -> i.getName().equals(rewardPolicy.getCustomerSelectitem())).findFirst().get();
            selectedValue.setChecked(true);
            if ("customers.select.other".equals(selectedValue.getName())) {
                ((ExtraInfoText) selectedValue.getExtraInfo()).setValue(rewardPolicy.getCustomerSelectitemText());
            }
        }

        // members
        if (rewardPolicy.getMembersChecked()) {
            RewardOption opt = ret.stream().filter(i -> i.getName().equals("members")).findFirst().get();
            opt.setChecked(true);
            ((ExtraInfoText) opt.getExtraInfo()).setValue(rewardPolicy.getMembersText());
        }

        // buy
        if (rewardPolicy.getBuyChecked()) {
            RewardOption opt = ret.stream().filter(i -> i.getName().equals("buy")).findFirst().get();
            opt.setChecked(true);
            ((ExtraInfoText) opt.getExtraInfo()).setValue(rewardPolicy.getBuyText());
        }

        // fee
        if (rewardPolicy.getFeeChecked()) {
            RewardOption opt = ret.stream().filter(i -> i.getName().equals("fee")).findFirst().get();
            opt.setChecked(true);
            ((ExtraInfoDecimal) opt.getExtraInfo()).setValue(rewardPolicy.getFeePrice());
        }

        return ret;
    }

    public List<RewardOption> updateCurrentPudoRewardPolicy(List<RewardOption> rewardPolicy) {
        Long pudoId = getCurrentPudoId();
        TbRewardPolicy newRewardPolicy = mapRewardPolicyDtoToEntity(rewardPolicy);
        Instant now = Instant.now();
        TbRewardPolicy oldRewardPolicy = rewardPolicyDao.getActiveRewardPolicy(pudoId);
        oldRewardPolicy.setDeleteTms(now);
        rewardPolicyDao.flush();
        newRewardPolicy.setPudoId(pudoId);
        newRewardPolicy.setCreateTms(now);
        newRewardPolicy.setDeleteTms(null);
        rewardPolicyDao.persist(newRewardPolicy);
        rewardPolicyDao.flush();
        log.info("[{}] Updated reward policy for PUDO: {}", context.getExecutionId(), pudoId);
        return getCurrentPudoRewardPolicy();
    }

    public List<PackageSummary> getCurrentPudoPackages(boolean history, int limit, int offset) {
        Long pudoId = getCurrentPudoId();
        return packageService.getPackages(AccountType.PUDO, pudoId, history, limit, offset);
    }

    public List<UserSummary> getCurrentPudoUsers() {
        Long pudoId = getCurrentPudoId();
        List<Quintet<Long, String, String, UUID, String>> rs = userPudoRelationDao.getActiveCustomersByPudoId(pudoId);
        return rs.stream().map(i -> dtoMapper.mapUserSummaryDto(i.getValue0(), i.getValue1(), i.getValue2(), i.getValue3(), i.getValue4())).collect(Collectors.toList());
    }

    protected Long getCurrentPudoId() {
        TbUser user = userDao.get(context.getUserId());
        if (user.getAccountType() != AccountType.PUDO) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        Long pudoId = userPudoRelationDao.getPudoIdByOwnerUserId(context.getUserId());
        if (pudoId == null) {
            log.fatal("[{}] User: {} has accountType: {}, but no ownership relation found", context.getExecutionId(), user.getUserId(), user.getAccountType());
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage(context.getLanguage(), "error.forbidden.wrong_account_type"));
        }
        return pudoId;
    }

    private String createPolicyMessage(TbRewardPolicy ent) {
        if (ent.getFreeChecked()) {
            return localizationService.getMessage(context.getLanguage(), "label.reward.free");
        }
        // grammars are different, so we must write custom block for every supported language, and we can't rely totally on message bundles
        Locale locale = isEmpty(context.getLanguage()) ? LocalizationService.DEFAULT_LOCALE : new Locale(context.getLanguage());
        StringBuilder sb = new StringBuilder();
        if (locale.equals(Locale.ITALIAN)) {
            if (ent.getCustomerChecked() || ent.getMembersChecked()) {
                sb.append("Il servizio è gratuito ");
                if (ent.getCustomerChecked()) {
                    sb.append(createCustomersPolicyMessage(ent, locale));
                }
                if (ent.getMembersChecked()) {
                    if (ent.getCustomerChecked()) {
                        sb.append(", ed anche ");
                    }
                    sb.append(createMembersPolicyMessage(ent, locale));
                }
                sb.append(". ");
            }
            if (ent.getBuyChecked() || ent.getFeeChecked()) {
                if (ent.getCustomerChecked() || ent.getMembersChecked()) {
                    sb.append("In alternativa puoi usufruire del servizio ");
                } else {
                    sb.append("Puoi usufruire del servizio ");
                }
                if (ent.getBuyChecked()) {
                    sb.append(createBuyPolicyMessage(ent, locale));
                }
                if (ent.getFeeChecked()) {
                    if (ent.getBuyChecked()) {
                        sb.append(", oppure ");
                    }
                    sb.append(createFeePolicyMessage(ent, locale));
                }
                sb.append(". ");
            }
        } else {
            if (ent.getCustomerChecked() || ent.getMembersChecked()) {
                sb.append("Service is free ");
                if (ent.getCustomerChecked()) {
                    sb.append(createCustomersPolicyMessage(ent, locale));
                }
                if (ent.getMembersChecked()) {
                    if (ent.getCustomerChecked()) {
                        sb.append(", and ");
                    }
                    sb.append(createMembersPolicyMessage(ent, locale));
                }
                sb.append(". ");
            }
            if (ent.getBuyChecked() || ent.getFeeChecked()) {
                if (ent.getCustomerChecked() || ent.getMembersChecked()) {
                    sb.append("Otherwise, you can have access to the service ");
                } else {
                    sb.append("You can have access to the service ");
                }
                if (ent.getBuyChecked()) {
                    sb.append(createBuyPolicyMessage(ent, locale));
                }
                if (ent.getFeeChecked()) {
                    if (ent.getBuyChecked()) {
                        sb.append(", or ");
                    }
                    sb.append(createFeePolicyMessage(ent, locale));
                }
                sb.append(". ");
            }
        }
        return sb.toString().trim();
    }

    private String createCustomersPolicyMessage(TbRewardPolicy ent, Locale locale) {
        StringBuilder sb = new StringBuilder();
        if (locale.equals(Locale.ITALIAN)) {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.customers.message"));
            sb.append(", cioè ");
            if (!ent.getCustomerSelectitem().equals("customers.select.other")) {
                sb.append("chi effettua almeno ");
                sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward." + ent.getCustomerSelectitem()).toLowerCase());
            } else {
                sb.append(ent.getCustomerSelectitemText());
            }
        } else {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.customers.message"));
            sb.append(", that is ");
            if (!ent.getCustomerSelectitem().equals("customers.select.other")) {
                sb.append("who does at least ");
                sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward." + ent.getCustomerSelectitem()).toLowerCase());
            } else {
                sb.append(ent.getCustomerSelectitemText());
            }
        }
        return sb.toString();
    }

    private String createMembersPolicyMessage(TbRewardPolicy ent, Locale locale) {
        StringBuilder sb = new StringBuilder();
        if (locale.equals(Locale.ITALIAN)) {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.members.message"));
            if (!isEmpty(ent.getMembersText())) {
                sb.append(", quali ");
                sb.append(ent.getMembersText());
            }
        } else {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.members.message"));
            if (!isEmpty(ent.getMembersText())) {
                sb.append(", such as ");
                sb.append(ent.getMembersText());
            }
        }
        return sb.toString();
    }

    private String createBuyPolicyMessage(TbRewardPolicy ent, Locale locale) {
        StringBuilder sb = new StringBuilder();
        if (locale.equals(Locale.ITALIAN)) {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.buy.message"));
            if (!isEmpty(ent.getBuyText())) {
                sb.append(", ad esempio ");
                sb.append(ent.getBuyText());
            }
        } else {
            sb.append(localizationService.getMessage(locale.getLanguage(), "label.reward.buy.message"));
            if (!isEmpty(ent.getBuyText())) {
                sb.append(", for example ");
                sb.append(ent.getBuyText());
            }
        }
        return sb.toString();
    }

    private String createFeePolicyMessage(TbRewardPolicy ent, Locale locale) {
        return localizationService.getMessage(locale.getLanguage(), "label.reward.fee.message", ent.getFeePrice().toString());
    }

    protected TbRewardPolicy mapRewardPolicyDtoToEntity(List<RewardOption> rewardPolicy) {
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
        if (free.getChecked() && rewardPolicy.stream().filter(RewardOption::getChecked).count() > 1) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
        }
        if (rewardPolicy.stream().noneMatch(RewardOption::getChecked)) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
        }

        // free for all
        ret.setFreeChecked(free.getChecked());

        // customers
        ret.setCustomerChecked(customers.getChecked());
        if (customers.getChecked()) {
            if (customers.getExtraInfo() == null || !(customers.getExtraInfo() instanceof ExtraInfoSelect)) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoSelect customersExtraInfo = (ExtraInfoSelect) customers.getExtraInfo();
            if (!customersExtraInfo.getName().equals("customers.select") || customersExtraInfo.getValues() == null || customersExtraInfo.getValues().isEmpty()) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            List<ExtraInfoSelectItem> values = customersExtraInfo.getValues();
            if (values.size() != 9) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            final List<String> allowedValueNames = Arrays.asList(
                    "customers.select.1/day",
                    "customers.select.3/week",
                    "customers.select.1/week",
                    "customers.select.2/month",
                    "customers.select.1/month",
                    "customers.select.4/year",
                    "customers.select.2/year",
                    "customers.select.1/year",
                    "customers.select.other"
            );
            for (String name : allowedValueNames) {
                if (values.stream().filter(i -> name.equals(i.getName())).count() != 1) {
                    throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
                }
            }
            if (values.stream().filter(ExtraInfoSelectItem::getChecked).count() > 1) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
            }
            ExtraInfoSelectItem selectedValue = values.stream().filter(ExtraInfoSelectItem::getChecked).findFirst().get();
            ret.setCustomerSelectitem(selectedValue.getName());
            if ("customers.select.other".equals(selectedValue.getName())) {
                if (selectedValue.getExtraInfo() == null || !(selectedValue.getExtraInfo() instanceof ExtraInfoText)) {
                    throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
                }
                ExtraInfoText otherExtraInfo = (ExtraInfoText) selectedValue.getExtraInfo();
                if (!otherExtraInfo.getName().equals("customers.select.other.text") || isEmpty(otherExtraInfo.getValue())) {
                    throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "rewardPolicy"));
                }
                ret.setCustomerSelectitemText(sanitizeString(otherExtraInfo.getValue()));
            }
        }

        // members
        ret.setMembersChecked(members.getChecked());
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
        ret.setBuyChecked(buy.getChecked());
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
        ret.setFeeChecked(fee.getChecked());
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

    protected String createCustomizedAddress(TbPudo pudo, TbAddress address, String customerSuffix) {
        StringBuilder sb = new StringBuilder();
        // first line: pudo name and customer suffix
        sb.append(pudo.getBusinessName());
        sb.append(" ");
        sb.append(customerSuffix);
        sb.append("\n");
        // second line: street and street number (if any)
        sb.append(address.getStreet());
        if (!isEmpty(address.getStreetNum())) {
            sb.append(" ");
            sb.append(address.getStreetNum());
        }
        sb.append("\n");
        // third line: zip code (if any), city and province
        if (!isEmpty(address.getZipCode())) {
            sb.append(address.getZipCode());
            sb.append(" ");
        }
        sb.append(address.getCity());
        sb.append(" (");
        sb.append(address.getProvince());
        sb.append(")");
        sb.append(", ");
        sb.append(address.getCountry());
        return sb.toString();
    }

}
