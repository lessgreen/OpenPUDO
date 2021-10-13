package less.green.openpudo.rest.resource;

import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.GeocodeService;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.GPSUtils;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.geojson.FeatureCollection;
import less.green.openpudo.rest.dto.map.*;
import less.green.openpudo.rest.dto.scalar.IntegerResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.math.BigDecimal;
import java.util.LinkedList;
import java.util.List;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Path("/map")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class MapResource {

    private static final int MIN_PUDO_COUNT_FOR_ZOOM_LEVEL = 10;
    private static final int MAX_PUDO_MARKER_COUNT_ON_MAP = 50;
    private static final int MAX_SEARCH_RESULT_GLOBAL = 30;
    private static final int MAX_SEARCH_RESULT_SLICE = 15;

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
    @Path("/suggested-zoom")
    @PublicAPI
    @Operation(summary = "Get suggested zoom for current location", description = "This is a public API and can be invoked without a valid access token.\n\n"
            + "This API calculates the minimum zoom level that provides enough PUDOs in user surroundings.")
    public IntegerResponse searchPudos(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon,
            @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "lon"));
        }

        // more sanitizing
        if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lat"));
        } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lon"));
        }

        for (int zoom = 16; zoom > 8; zoom--) {
            List<PudoMarker> rs = pudoService.searchPudosByCoordinates(lat, lon, zoom);
            if (rs.size() >= MIN_PUDO_COUNT_FOR_ZOOM_LEVEL) {
                return new IntegerResponse(context.getExecutionId(), ApiReturnCodes.OK, zoom);
            }
        }
        return new IntegerResponse(context.getExecutionId(), ApiReturnCodes.OK, 8);
    }

    @GET
    @Path("/pudos")
    @PublicAPI
    @Operation(summary = "Get PUDO markers to show on current map", description = "This is a public API and can be invoked without a valid access token.\n\n")
    public PudoMarkerListResponse searchPudosByCoordinates(
            @Parameter(description = "Latitude value of map center point", required = true) @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point", required = true) @QueryParam("lon") BigDecimal lon,
            @Parameter(description = "Zoom level according to https://wiki.openstreetmap.org/wiki/Zoom_levels, must be between 8 and 16", required = true) @QueryParam("zoom") Integer zoom,
            @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (lat == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "lat"));
        } else if (lon == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "lon"));
        } else if (zoom == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "zoom"));
        }

        // more sanitizing
        if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lat"));
        } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lon"));
        } else if (zoom < 8 || zoom > 16) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "zoom"));
        }

        List<PudoMarker> rs = pudoService.searchPudosByCoordinates(lat, lon, zoom);
        // restricting results if necessary, sorting by distance
        if (rs.size() > MAX_PUDO_MARKER_COUNT_ON_MAP) {
            rs = GPSUtils.sortByDistance(rs, lat.doubleValue(), lon.doubleValue());
            rs = rs.subList(0, MAX_PUDO_MARKER_COUNT_ON_MAP);
        }
        return new PudoMarkerListResponse(context.getExecutionId(), ApiReturnCodes.OK, rs);
    }

    @GET
    @Path("/search/addresses")
    @PublicAPI
    @Operation(summary = "Address search feature based on user input autocompletion",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
                    + "Coordinates parameters are optional, but the client should provide them to speed up queries and obtain more pertinent results.\n\n"
                    + "This API should be throttled to prevent excessive load.")
    public AddressMarkerListResponse searchAddresses(
            @Parameter(description = "Query text", required = true) @QueryParam("text") String text,
            @Parameter(description = "Latitude value of map center point") @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point") @QueryParam("lon") BigDecimal lon,
            @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (isEmpty(text)) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "text"));
        }

        // more sanitizing
        if (lat != null && lon != null) {
            if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lat"));
            } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lon"));
            }
        }

        try {
            FeatureCollection fc = geocodeService.autocomplete(text, lat, lon);
            List<Feature> rs = fc.getFeatures();
            // restricting results if necessary (unlikely)
            if (rs.size() > MAX_SEARCH_RESULT_GLOBAL) {
                rs = rs.subList(0, MAX_SEARCH_RESULT_SLICE);
            }
            return new AddressMarkerListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapFeatureListToAddressMarkerList(rs));
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(language, "error.service_unavailable"));
        }
    }

    @GET
    @Path("/search")
    @PublicAPI
    @Operation(summary = "Global search feature based on user input autocompletion",
            description = "This is a public API and can be invoked without a valid access token.\n\n"
                    + "This API search between PUDOs that matches business name (even partially) and addresses.\n\n"
                    + "Coordinates parameters are optional, but the client should provide them to speed up queries and obtain more pertinent results.\n\n"
                    + "This API should be throttled to prevent excessive load.")
    public MarkerListResponse search(
            @Parameter(description = "Query text", required = true) @QueryParam("text") String text,
            @Parameter(description = "Latitude value of map center point") @QueryParam("lat") BigDecimal lat,
            @Parameter(description = "Longitude value of map center point") @QueryParam("lon") BigDecimal lon,
            @HeaderParam("Application-Language") String language) {
        // sanitize input
        if (isEmpty(text)) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.empty_mandatory_field", "text"));
        }

        // more sanitizing
        if (lat != null && lon != null) {
            if (lat.compareTo(BigDecimal.valueOf(-90)) < 0 || lat.compareTo(BigDecimal.valueOf(90)) > 0) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lat"));
            } else if (lon.compareTo(BigDecimal.valueOf(-180)) < 0 || lat.compareTo(BigDecimal.valueOf(180)) > 0) {
                throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage(language, "error.invalid_field", "lon"));
            }
        }

        // searching pudos
        List<Marker> ret = new LinkedList<>();
        List<PudoMarker> prs = pudoService.searchPudosByName(text);
        // sorting by distance, if we have optional coordinates
        if (lat != null && lon != null) {
            prs = GPSUtils.sortByDistance(prs, lat.doubleValue(), lon.doubleValue());
        }

        // searching adresses
        List<Feature> frs;
        try {
            FeatureCollection fc = geocodeService.autocomplete(text, lat, lon);
            frs = fc.getFeatures();
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(language, "error.service_unavailable"));
        }

        // restricting results if necessary
        if (prs.size() + frs.size() > MAX_SEARCH_RESULT_GLOBAL) {
            if (prs.size() >= MAX_SEARCH_RESULT_SLICE && frs.size() >= MAX_SEARCH_RESULT_SLICE) {
                // if both subsearches have too many results
                prs = prs.subList(0, MAX_SEARCH_RESULT_SLICE);
                frs = frs.subList(0, MAX_SEARCH_RESULT_SLICE);
            } else if (prs.size() >= MAX_SEARCH_RESULT_SLICE) {
                // if too many pudos only
                prs = prs.subList(0, MAX_SEARCH_RESULT_GLOBAL - frs.size());
            } else {
                // if too many addresses only (unlikely)
                frs = frs.subList(0, MAX_SEARCH_RESULT_GLOBAL - prs.size());
            }
        }

        // combining results
        for (PudoMarker pudo : prs) {
            ret.add(new Marker(MarkerType.PUDO, pudo));
        }
        for (Feature feat : frs) {
            ret.add(new Marker(MarkerType.ADDRESS, dtoMapper.mapFeatureToAddressMarker(feat)));
        }

        return new MarkerListResponse(context.getExecutionId(), 0, ret);
    }

}
