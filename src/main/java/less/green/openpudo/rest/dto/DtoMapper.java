package less.green.openpudo.rest.dto;

import less.green.openpudo.business.model.TbUserPreferences;
import less.green.openpudo.business.model.TbUserProfile;
import less.green.openpudo.common.GPSUtils;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.Point;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.user.UserPreferences;
import less.green.openpudo.rest.dto.user.UserProfile;
import org.mapstruct.Mapper;

import java.math.BigDecimal;
import java.util.Map;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    UserProfile mapUserProfileEntityToDto(TbUserProfile ent, String phoneNumber, Long packageCount);

    UserPreferences mapUserPreferencesEntityToDto(TbUserPreferences ent);

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
            ret.setDistanceFromOrigin(BigDecimal.valueOf(GPSUtils.haversineDistance(lat.doubleValue(), lon.doubleValue(), ret.getLat().doubleValue(), ret.getLon().doubleValue())));
        }
        return ret;
    }

}
