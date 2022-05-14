package less.green.openpudo.rest.dto;

import less.green.openpudo.business.model.*;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.Point;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.AddressSearchResult;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.notification.Notification;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageEvent;
import less.green.openpudo.rest.dto.pack.PackageSummary;
import less.green.openpudo.rest.dto.pudo.Address;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import less.green.openpudo.rest.dto.pudo.Rating;
import less.green.openpudo.rest.dto.user.User;
import less.green.openpudo.rest.dto.user.UserPreferences;
import less.green.openpudo.rest.dto.user.UserSummary;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    User mapUserDto(TbUserProfile userProfile, String phoneNumber, Long packageCount, String savedCO2, String customerSuffix);

    UserPreferences mapUserPreferencesDto(TbUserPreferences userPreferences);

    UserSummary mapUserSummaryDto(Long userId, String firstName, String lastName, UUID profilePicId, String customerSuffix);

    @Mapping(source = "pudo.pudoId", target = "pudoId")
    @Mapping(source = "pudo.createTms", target = "createTms")
    @Mapping(source = "pudo.updateTms", target = "updateTms")
    Pudo mapPudoDto(TbPudo pudo, TbAddress address, TbRating rating, String rewardMessage, Long customerCount, Long packageCount, String savedCO2, String customizedAddress);

    Address mapAddressDto(TbAddress address);

    Rating mapRatingDto(TbRating rating);

    @Mapping(target = "pudoId", ignore = true)
    @Mapping(target = "createTms", ignore = true)
    @Mapping(target = "updateTms", ignore = true)
    TbAddress mapAddressEntity(AddressSearchResult addressSearchResult);

    @Mapping(source = "pudoId", target = "pudoId")
    PudoSummary mapPudoSummaryDto(Long pudoId, String businessName, UUID pudoPicId, String label, TbRating rating, String customizedAddress);

    Package mapPackageDto(TbPackage pack, List<PackageEvent> events, String packageName, String shareLink);

    PackageEvent mapPackageEventDto(TbPackageEvent packageEvent, String packageStatusMessage);

    @Mapping(source = "localizedTitle", target = "title")
    @Mapping(source = "localizedMessage", target = "message")
    Notification mapNotificationDto(TbNotification notification, String localizedTitle, String localizedMessage, Map<String, String> optData);

    @Mapping(source = "pack.packageId", target = "packageId")
    @Mapping(source = "pack.createTms", target = "createTms")
    @Mapping(source = "pudo.pudoId", target = "pudoId")
    @Mapping(source = "userProfile.userId", target = "userId")
    PackageSummary mapPackageSummaryDto(TbPackage pack, TbPackageEvent event, TbPudo pudo, TbAddress address, TbUserProfile userProfile, TbUserPudoRelation userPudoRelation, String packageName);

    @Mapping(target = "signature", ignore = true)
    PudoMarker mapPudoMarkerDto(PudoSummary pudo, BigDecimal lat, BigDecimal lon, BigDecimal distanceFromOrigin);

    @Mapping(source = "address", target = "address")
    @Mapping(source = "lat", target = "lat")
    @Mapping(source = "lon", target = "lon")
    AddressMarker mapAddressMarkerDto(AddressSearchResult address, String signature, BigDecimal lat, BigDecimal lon, BigDecimal distanceFromOrigin);

    default AddressSearchResult mapFeatureToAddressSearchResult(Feature feat) {
        if (feat == null) {
            return null;
        }
        AddressSearchResult ret = new AddressSearchResult();
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
        return ret;
    }

}
