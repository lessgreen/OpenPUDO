package less.green.openpudo.rest.resource;

import java.math.BigDecimal;
import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.GeocodeService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import static less.green.openpudo.common.StringUtils.isEmpty;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.geojson.FeatureCollection;
import less.green.openpudo.rest.dto.map.AutocompleteResultListResponse;
import less.green.openpudo.rest.dto.pudo.PudoListResponse;
import less.green.openpudo.rest.dto.scalar.IntegerResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

@RequestScoped
@Path("/map")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class MapResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;
    @Inject
    GeocodeService geocodeService;
    @Inject
    DtoMapper dtoMapper;

    @Inject
    PudoService pudoService;

    @GET
    @Path("/suggested-zoom")
    @Operation(summary = "Get suggested zoom for current location", description = "This is currently a stubbed API, that returns a fixed value of 12.")
    public IntegerResponse searchPudos(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "lon"));
        }
        return new IntegerResponse(context.getExecutionId(), ApiReturnCodes.OK, 12);
    }

    @GET
    @Path("/pudos/search")
    @Operation(summary = "Get PUDO markers to show on current map")
    public PudoListResponse searchPudos(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon,
            @Parameter(description = "Zoom level according to https://wiki.openstreetmap.org/wiki/Zoom_levels, must be between 8 and 16", required = true) @QueryParam("zoom") Integer zoom) {
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

        List<PudoAndAddress> rs = pudoService.searchPudo(lat, lon, zoom);
        return new PudoListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPudoEntityListToDtoList(rs));
    }

    @GET
    @Path("/address/autocomplete")
    @Operation(summary = "Address autocomplete feature",
            description = "Coordinates parameters are optional, but the client should provide them to speed up queries and obtain more pertinent results.\n\n"
            + "This API should be throttled to prevent excessive load.")
    public AutocompleteResultListResponse autocomplete(
            @Parameter(description = "Query text", required = true) @QueryParam("text") String text,
            @Parameter(description = "Latitude value of map center point") @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point") @QueryParam("lon") BigDecimal lon) {
        // sanitize input
        if (isEmpty(text)) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "text"));
        }

        try {
            FeatureCollection rs = geocodeService.autocomplete(text, lat, lon);
            return new AutocompleteResultListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapFeatureToAutocompleteResult(rs.getFeatures()));
        } catch (RuntimeException ex) {
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

}
