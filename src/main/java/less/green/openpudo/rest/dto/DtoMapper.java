package less.green.openpudo.rest.dto;

import less.green.openpudo.business.model.TbAddress;
import less.green.openpudo.business.model.TbUserPreferences;
import less.green.openpudo.business.model.TbUserProfile;
import less.green.openpudo.common.GPSUtils;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.Point;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import less.green.openpudo.rest.dto.user.UserPreferences;
import less.green.openpudo.rest.dto.user.UserProfile;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    UserProfile mapUserProfileEntityToDto(TbUserProfile ent, String phoneNumber, String customerSuffix, Long packageCount);

    UserPreferences mapUserPreferencesEntityToDto(TbUserPreferences ent);

    TbAddress mapAddressMarkerToAddressEntity(AddressMarker dto);

    @Mapping(source = "values.value0", target = "pudoId")
    @Mapping(source = "values.value1", target = "lat")
    @Mapping(source = "values.value2", target = "lon")
    @Mapping(source = "values.value3", target = "distanceFromOrigin")
    PudoMarker mapProjectionToPudoMarker(Quartet<Long, BigDecimal, BigDecimal, BigDecimal> values);

    List<PudoMarker> mapProjectionListToPudoMarkerList(List<Quartet<Long, BigDecimal, BigDecimal, BigDecimal>> values);

    @Mapping(source = "values.value0", target = "pudoId")
    @Mapping(source = "values.value1", target = "businessName")
    @Mapping(source = "values.value2", target = "pudoPicId")
    @Mapping(source = "values.value3", target = "label")
    PudoSummary mapProjectionToPudoSummary(Quartet<Long, String, UUID, String> values);

    List<PudoSummary> mapProjectionListToPudoSummaryList(List<Quartet<Long, String, UUID, String>> values);

    default AddressMarker mapFeatureToAddressMarker(Feature feat, BigDecimal lat, BigDecimal lon) {
        if (feat == null) {
            return null;
        }
        AddressMarker ret = new AddressMarker();
        Map<String, Object> properties = feat.getProperties();
        ret.setLabel((String) properties.get("label"));
        ret.setStreet((String) properties.get("street"));
        ret.setStreetNum((String) properties.get("housenumber"));
        ret.setZipCode((String) properties.get("postalcode"));
        ret.setCity((String) properties.get("locality"));
        ret.setProvince((String) properties.get("region"));
        ret.setCountry((String) properties.get("country"));
        Point geometry = feat.getGeometry();
        ret.setLat(geometry.getCoordinates().get(1));
        ret.setLon(geometry.getCoordinates().get(0));
        if (lat != null && lon != null) {
            ret.setDistanceFromOrigin(GPSUtils.calculateDistanceFromOrigin(lat, lon, ret.getLat(), ret.getLon()));
        }
        return ret;
    }

}
