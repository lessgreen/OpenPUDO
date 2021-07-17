package less.green.openpudo.rest.dto;

import java.util.List;
import java.util.Map;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.rest.dto.address.Address;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.geojson.Point;
import less.green.openpudo.rest.dto.map.AddressMarker;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    @Mapping(source = "ent.value0", target = ".")
    @Mapping(source = "ent.value1", target = "pudoOwner")
    User mapUserEntityToDto(Pair<TbUser, Boolean> ent);

    List<User> mapUserEntityListToDtoList(List<Pair<TbUser, Boolean>> ents);

    Address mapAddressEntityToDto(TbAddress ent);

    @Mapping(source = "ent.value0", target = ".")
    @Mapping(source = "ent.value1", target = "address")
    Pudo mapPudoEntityToDto(Pair<TbPudo, TbAddress> ent);

    List<Pudo> mapPudoEntityListToDtoList(List<Pair<TbPudo, TbAddress>> ents);

    @Mapping(source = "ent.value0", target = ".")
    @Mapping(source = "ent.value1", target = "events")
    Package mapPackageEntityToDto(Pair<TbPackage, List<TbPackageEvent>> ent);

    default AddressMarker mapFeatureToAddressMarker(Feature feat) {
        if (feat == null) {
            return null;
        }
        AddressMarker ret = new AddressMarker();
        Map<String, Object> properties = feat.getProperties();
        ret.setLabel((String) properties.get("label"));
        ret.setResultId((String) properties.get("gid"));
        ret.setPrecision((String) properties.get("layer"));
        Point geometry = feat.getGeometry();
        ret.setLat(geometry.getCoordinates().get(1));
        ret.setLon(geometry.getCoordinates().get(0));
        return ret;
    }

    default void mapFeatureToExistingAddressEntity(Feature feat, TbAddress ent) {
        if (feat == null) {
            return;
        }
        Map<String, Object> properties = feat.getProperties();
        ent.setLabel((String) properties.get("label"));
        ent.setStreet((String) properties.get("street"));
        ent.setStreetNum((String) properties.get("housenumber"));
        ent.setZipCode((String) properties.get("postalcode"));
        ent.setCity((String) properties.get("locality"));
        ent.setProvince((String) properties.get("region"));
        ent.setCountry((String) properties.get("country"));
        Point geometry = feat.getGeometry();
        ent.setLat(geometry.getCoordinates().get(1));
        ent.setLon(geometry.getCoordinates().get(0));
    }

    List<AddressMarker> mapFeatureListToAddressMarkerList(List<Feature> feat);

}
