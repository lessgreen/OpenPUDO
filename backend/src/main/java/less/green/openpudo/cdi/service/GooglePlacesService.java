package less.green.openpudo.cdi.service;

import com.google.maps.GeoApiContext;
import com.google.maps.PlaceAutocompleteRequest;
import com.google.maps.PlacesApi;
import com.google.maps.model.*;
import io.quarkus.runtime.Startup;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.AddressSearchResult;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import javax.enterprise.context.ApplicationScoped;
import javax.inject.Inject;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

import static less.green.openpudo.common.GPSUtils.calculateDistanceFromOrigin;
import static less.green.openpudo.common.StringUtils.isEmpty;

@ApplicationScoped
@Startup
@Log4j2
public class GooglePlacesService {

    @Inject
    DtoMapper dtoMapper;

    @ConfigProperty(name = "google.places.api.key")
    String apiKey;

    private GeoApiContext geoApiContext;

    @PostConstruct
    void init() {
        geoApiContext = new GeoApiContext.Builder().apiKey(apiKey).connectTimeout(5, TimeUnit.SECONDS).readTimeout(5, TimeUnit.SECONDS).build();
    }

    public List<AddressMarker> autocomplete(UUID sessionToken, String language, String text, BigDecimal lat, BigDecimal lon) {
        PlaceAutocompleteRequest request = PlacesApi.placeAutocomplete(geoApiContext, text, new PlaceAutocompleteRequest.SessionToken(sessionToken));
        request.types(PlaceAutocompleteType.ADDRESS);
        if (!isEmpty(language)) {
            request.language(language);
        }
        if (lat != null && lon != null) {
            var latlng = new LatLng(lat.doubleValue(), lon.doubleValue());
            request.location(latlng).origin(latlng);
        }
        try {
            AutocompletePrediction[] predictions = request.await();
            if (predictions == null || predictions.length == 0) {
                return Collections.emptyList();
            }
            List<AddressMarker> ret = new ArrayList<>(predictions.length);
            for (var prediction : predictions) {
                AddressSearchResult address = new AddressSearchResult();
                address.setLabel(prediction.description);
                ret.add(dtoMapper.mapAddressMarkerDto(address, prediction.placeId, null, null, prediction.distanceMeters != null ? BigDecimal.valueOf(prediction.distanceMeters).divide(BigDecimal.valueOf(1000), 3, RoundingMode.HALF_UP) : null));
            }
            return ret;
        } catch (Exception ex) {
            throw new RuntimeException("Google Places service unavailable", ex);
        }
    }

    public AddressMarker getAddressDetails(UUID sessionToken, String language, String placeId, BigDecimal lat, BigDecimal lon) {
        var request = PlacesApi.placeDetails(geoApiContext, placeId, new PlaceAutocompleteRequest.SessionToken(sessionToken));
        if (!isEmpty(language)) {
            request.language(language);
        }
        try {
            PlaceDetails place = request.await();
            AddressSearchResult address = new AddressSearchResult();
            address.setLabel(place.formattedAddress);

            AddressComponent component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.ROUTE)).findFirst().orElse(null);
            if (component != null) {
                address.setStreet(component.longName);
            }
            component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.STREET_NUMBER)).findFirst().orElse(null);
            if (component != null) {
                address.setStreetNum(component.longName);
            }
            component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.POSTAL_CODE)).findFirst().orElse(null);
            if (component != null) {
                address.setZipCode(component.longName);
            }
            component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.ADMINISTRATIVE_AREA_LEVEL_3)).findFirst().orElse(null);
            if (component != null) {
                address.setCity(component.longName);
            }
            component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.ADMINISTRATIVE_AREA_LEVEL_2)).findFirst().orElse(null);
            if (component != null) {
                address.setProvince(component.shortName);
            }
            component = Arrays.stream(place.addressComponents).filter(i -> Arrays.stream(i.types).collect(Collectors.toList()).contains(AddressComponentType.COUNTRY)).findFirst().orElse(null);
            if (component != null) {
                address.setCountry(component.longName);
            }

            if (place.geometry != null && place.geometry.location != null) {
                address.setLat(BigDecimal.valueOf(place.geometry.location.lat));
                address.setLon(BigDecimal.valueOf(place.geometry.location.lng));
            }
            BigDecimal distanceFromOrigin = lat != null && lon != null ? calculateDistanceFromOrigin(address.getLat(), address.getLon(), lat, lon) : null;
            return dtoMapper.mapAddressMarkerDto(address, placeId, address.getLat(), address.getLon(), distanceFromOrigin);
        } catch (Exception ex) {
            throw new RuntimeException("Google Places service unavailable", ex);
        }
    }

    @PreDestroy
    void cleanup() {
        geoApiContext.shutdown();
    }

}
