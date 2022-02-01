package less.green.openpudo.rest.dto;

import less.green.openpudo.business.model.*;
import less.green.openpudo.common.dto.geojson.Feature;
import less.green.openpudo.common.dto.geojson.Point;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.common.dto.tuple.Quintet;
import less.green.openpudo.common.dto.tuple.Septet;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.map.AddressSearchResult;
import less.green.openpudo.rest.dto.map.PudoMarker;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageEvent;
import less.green.openpudo.rest.dto.pudo.Address;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.pudo.PudoSummary;
import less.green.openpudo.rest.dto.pudo.Rating;
import less.green.openpudo.rest.dto.user.User;
import less.green.openpudo.rest.dto.user.UserPreferences;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    User mapUserProfileEntityToDto(TbUserProfile ent, String phoneNumber, Long packageCount, String customerSuffix);

    UserPreferences mapUserPreferencesEntityToDto(TbUserPreferences ent);

    @Mapping(source = "ent.value0", target = ".")
    @Mapping(source = "ent.value1", target = "address")
    @Mapping(source = "ent.value2", target = "rating")
    @Mapping(source = "ent.value3", target = "rewardMessage")
    @Mapping(source = "ent.value4", target = "customerCount")
    @Mapping(source = "ent.value5", target = "packageCount")
    @Mapping(source = "ent.value6", target = "customizedAddress")
    Pudo mapPudoEntityToDto(Septet<TbPudo, TbAddress, TbRating, String, Long, Long, String> ent);

    Address mapAddressEntityToDto(TbAddress ent);

    Rating mapRatingEntityToDto(TbRating ent);

    @Mapping(target = "pudoId", ignore = true)
    @Mapping(target = "createTms", ignore = true)
    @Mapping(target = "updateTms", ignore = true)
    TbAddress mapAddressSearchResultToAddressEntity(AddressSearchResult dto);

    @Mapping(source = "values.value0", target = "pudoId")
    @Mapping(source = "values.value1", target = "businessName")
    @Mapping(source = "values.value2", target = "pudoPicId")
    @Mapping(source = "values.value3", target = "label")
    @Mapping(source = "values.value4", target = "rating")
    PudoSummary mapProjectionToPudoSummary(Quintet<Long, String, UUID, String, TbRating> values);

    List<PudoSummary> mapProjectionListToPudoSummaryList(List<Quintet<Long, String, UUID, String, TbRating>> values);

    @Mapping(source = "ent.value0", target = ".")
    @Mapping(source = "ent.value1", target = "events")
    Package mapPackageEntityToDto(Pair<TbPackage, List<TbPackageEvent>> ent);

    PackageEvent mapPackageEventEntityToDto(TbPackageEvent ent);

    @Mapping(source = "values.value0", target = "pudo")
    @Mapping(source = "values.value1", target = "lat")
    @Mapping(source = "values.value2", target = "lon")
    @Mapping(source = "values.value3", target = "distanceFromOrigin")
    @Mapping(target = "signature", ignore = true)
    PudoMarker mapProjectionToPudoMarker(Quartet<PudoSummary, BigDecimal, BigDecimal, BigDecimal> values);

    @Mapping(source = "values.value0", target = "address")
    @Mapping(source = "values.value1", target = "signature")
    @Mapping(source = "values.value2", target = "lat")
    @Mapping(source = "values.value3", target = "lon")
    @Mapping(source = "values.value4", target = "distanceFromOrigin")
    AddressMarker mapProjectionToAddressMarker(Quintet<AddressSearchResult, String, BigDecimal, BigDecimal, BigDecimal> values);

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
