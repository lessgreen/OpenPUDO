package less.green.openpudo.rest.resource;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.GeocodeService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import static less.green.openpudo.common.FormatUtils.safeNormalizePhoneNumber;
import less.green.openpudo.common.MultipartUtils;
import static less.green.openpudo.common.MultipartUtils.ALLOWED_IMAGE_MIME_TYPES;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.BinaryAPI;
import less.green.openpudo.rest.config.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.address.AddressRequest;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoResponse;
import less.green.openpudo.rest.dto.user.UserListResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

@RequestScoped
@Path("/pudos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class PudoResource {

    @Inject
    ExecutionContext context;

    @Inject
    GeocodeService geocodeService;
    @Inject
    LocalizationService localizationService;

    @Inject
    PudoService pudoService;

    @Inject
    DtoMapper dtoMapper;

    @GET
    @Path("/{pudoId}")
    @Operation(summary = "Get public info for PUDO with provided pudoId", description = "This is a public API and can be invoked without a valid access token.")
    @PublicAPI
    public PudoResponse getPudoById(@PathParam(value = "pudoId") Long pudoId) {
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoById(pudoId);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @GET
    @Path("/me")
    @Operation(summary = "Get public info for current PUDO")
    public PudoResponse getCurrentPudo() {
        // checking permission
        Pair<TbPudo, TbAddress> pudo = pudoService.getPudoByOwner(context.getUserId());
        if (pudo == null) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @PUT
    @Path("/me")
    @Operation(summary = "Update public info for current PUDO")
    public PudoResponse updateCurrentPudo(Pudo req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getBusinessName())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "businessName"));
        }

        // more sanitizing
        if (!isEmpty(req.getPhoneNumber())) {
            String npn = safeNormalizePhoneNumber(req.getPhoneNumber());
            if (npn == null) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "phoneNumber"));
            }
            req.setPhoneNumber(npn);
        }

        // checking permission
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (!pudoOwner) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }

        Pair<TbPudo, TbAddress> pudo = pudoService.updatePudoByOwner(context.getUserId(), req);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @PUT
    @Path("/me/address")
    @Operation(summary = "Update address for current PUDO")
    public PudoResponse updateCurrentPudoAddress(AddressRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (isEmpty(req.getLabel())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "label"));
        } else if (isEmpty(req.getResultId())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "resultId"));
        }

        // checking permission
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (!pudoOwner) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }

        // geocoding
        Feature feat;
        try {
            feat = geocodeService.search(req.getLabel(), req.getResultId());
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }

        if (feat == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.address.invalid_address"));
        }

        Pair<TbPudo, TbAddress> pudo = pudoService.updatePudoAddressByOwner(context.getUserId(), feat);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @PUT
    @Path("/me/profile-pic")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @Operation(summary = "Update public profile picture for current PUDO")
    public PudoResponse updateCurrentPudoProfilePic(MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = MultipartUtils.readUploadedFile(req);
        } catch (IOException ex) {
            log.error(ex.getMessage());
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "multipart name"));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "mimeType"));
        }

        // checking permission
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (!pudoOwner) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }

        try {
            Pair<TbPudo, TbAddress> pudo = pudoService.updatePudoProfilePicByOwner(context.getUserId(), uploadedFile.getValue0(), uploadedFile.getValue1());
            return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

    @DELETE
    @Path("/me/profile-pic")
    @Operation(summary = "Delete public profile picture for current PUDO")
    public PudoResponse deleteCurrentUserProfilePic() {
        try {
            Pair<TbPudo, TbAddress> pudo = pudoService.deletePudoProfilePicByOwner(context.getUserId());
            return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

    @GET
    @Path("/me/users")
    @Operation(summary = "Get current PUDO's user list")
    public UserListResponse getCurrentPudoUsers() {
        // checking permission
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (!pudoOwner) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }
        List<TbUser> users = pudoService.getUserListByPudoOwner(context.getUserId());
        // since they are all customers, we assume pudoOwner = false
        List<Pair<TbUser, Boolean>> customers = users.stream().map(i -> new Pair<TbUser, Boolean>(i, false)).collect(Collectors.toList());
        return new UserListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapUserEntityListToDtoList(customers));
    }

}
