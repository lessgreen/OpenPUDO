package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.PudoService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.MultipartUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.annotation.ProtectedAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoResponse;
import less.green.openpudo.rest.dto.pudo.reward.*;
import less.green.openpudo.rest.dto.scalar.UUIDResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import static less.green.openpudo.common.MultipartUtils.ALLOWED_IMAGE_MIME_TYPES;

@RequestScoped
@Path("/pudo")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class PudoResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    PudoService pudoService;

    @GET
    @Path("/{pudoId}")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for specific PUDO")
    public PudoResponse getPudo(@PathParam(value = "pudoId") Long pudoId) {
        Pudo ret = pudoService.getPudo(pudoId);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/me")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get profile for current PUDO")
    public PudoResponse getCurrentPudo() {
        Pudo ret = pudoService.getCurrentPudo();
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @PUT
    @Path("/me/picture")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update picture for current PUDO")
    public UUIDResponse updateCurrentPudoPicture(MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = MultipartUtils.readUploadedFile(req);
        } catch (IOException ex) {
            log.error(ex.getMessage());
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "multipart name"));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "mimeType"));
        }

        UUID ret = pudoService.updateCurrentPudoPicture(uploadedFile.getValue0(), uploadedFile.getValue1());
        return new UUIDResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/reward-schema")
    @PublicAPI
    @Operation(summary = "Get PUDO rewards definition schema")
    public RewardOptionListResponse getRewardSchema() {
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
        feeExtraInfo.setMin(BigDecimal.valueOf(0.1));
        feeExtraInfo.setMax(BigDecimal.valueOf(2.0));
        feeExtraInfo.setScale(2);
        feeExtraInfo.setStep(BigDecimal.valueOf(0.1));
        return new RewardOptionListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
