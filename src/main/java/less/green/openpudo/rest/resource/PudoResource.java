package less.green.openpudo.rest.resource;

import java.math.BigDecimal;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import static less.green.openpudo.common.FormatUtils.safeNormalizePhoneNumber;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoListResponse;
import less.green.openpudo.rest.dto.pudo.PudoResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/pudos")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class PudoResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;
    @Inject
    DtoMapper dtoMapper;

    @Inject
    PudoService pudoService;

    @GET
    @Path("/{pudoId}")
    @Operation(summary = "Get public info for PUDO with provided pudoId")
    public PudoResponse getPudoById(@PathParam(value = "pudoId") Long pudoId) {
        PudoAndAddress pudo = pudoService.getPudoAndAddressById(pudoId);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @GET
    @Path("/mine")
    @Operation(summary = "Get public info for PUDO owned by current user")
    public PudoResponse getCurrentPudo() {
        PudoAndAddress pudo = pudoService.getPudoAndAddressByOwnerUserId(context.getUserId());
        if (pudo == null) {
            throw new ApiException(ApiReturnCodes.UNAUTHORIZED, localizationService.getMessage("error.pudo.not_pudo_owner"));
        }
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @PUT
    @Path("/mine")
    @Operation(summary = "Update public profile for current user")
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

        Long pudoId = pudoService.getPudoIdByOwnerUserId(context.getUserId());
        if (pudoId == null) {
            throw new ApiException(ApiReturnCodes.UNAUTHORIZED, localizationService.getMessage("error.pudo.not_pudo_owner"));
        }

        PudoAndAddress pudo = pudoService.updatePudoByOwnerUserId(context.getUserId(), req);
        return new PudoResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityToDto(pudo));
    }

    @GET
    @Path("/search")
    @Operation(summary = "Search PUDO by business name")
    public PudoListResponse searchPudos(@Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon,
            @Parameter(description = "Zoom level according to https://wiki.openstreetmap.org/wiki/Zoom_levels, must be between 8 and 16", required = true) @QueryParam("zoom") Integer zoom,
            @Parameter(description = "String to filter results using full text search") @QueryParam("businessName") String businessName) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lon"));
        } else if (zoom == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "zoom"));
        }

        // more sanitizing
        if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "lat"));
        } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "lon"));
        } else if (zoom < 8 || zoom > 16) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "zoom"));
        }

        List<PudoAndAddress> rs = pudoService.searchPudo(lat, lon, zoom, businessName);
        return new PudoListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityListToDtoList(rs));
    }
}
