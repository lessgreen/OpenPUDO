package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.MapService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.annotation.ProtectedAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.map.PudoMarkerListResponse;
import less.green.openpudo.rest.dto.map.SignedAddressMarker;
import less.green.openpudo.rest.dto.map.SignedAddressMarkerListResponse;
import less.green.openpudo.rest.dto.scalar.IntegerResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.math.BigDecimal;
import java.util.List;

import static less.green.openpudo.common.StringUtils.isEmpty;

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
    MapService mapService;

    @GET
    @Path("/search/address")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Address search feature based on user input autocompletion",
            description = "Coordinates parameters are optional, but the client should provide them to speed up queries and obtain more pertinent results.\n\n"
                    + "This API should be throttled to prevent excessive load.")
    public SignedAddressMarkerListResponse searchAddress(
            @Parameter(description = "Query text", required = true) @QueryParam("text") String text,
            @Parameter(description = "Latitude value of map center point") @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point") @QueryParam("lon") BigDecimal lon) {
        // sanitize input
        if (isEmpty(text)) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "text"));
        }

        // more sanitizing
        if (lat != null && lon != null) {
            if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lat"));
            } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
                throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lon"));
            }
        }

        List<SignedAddressMarker> ret = mapService.searchAddress(text, lat, lon);
        return new SignedAddressMarkerListResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/suggested-zoom")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get suggested zoom for current location", description = "This API calculates the minimum zoom level that provides enough PUDOs in user surroundings.")
    public IntegerResponse getSuggestedZoom(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "lon"));
        }

        // more sanitizing
        if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lat"));
        } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lon"));
        }

        Integer ret = mapService.getSuggestedZoom(lat, lon);
        return new IntegerResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @GET
    @Path("/pudos")
    @ProtectedAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get PUDO markers to show on current map", description = "This API should be throttled to prevent excessive load")
    public PudoMarkerListResponse getPudosOnMap(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon,
            @Parameter(description = "Zoom level according to https://wiki.openstreetmap.org/wiki/Zoom_levels, must be between 8 and 16", required = true) @QueryParam("zoom") Integer zoom) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "lon"));
        } else if (zoom == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "zoom"));
        }

        // more sanitizing
        if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lat"));
        } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "lon"));
        } else if (zoom < 8 || zoom > 16) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "zoom"));
        }

        List<PudoMarker> rs = mapService.getPudosOnMap(lat, lon, zoom);
        return new PudoMarkerListResponse(context.getExecutionId(), ApiReturnCodes.OK, rs);
    }

}
