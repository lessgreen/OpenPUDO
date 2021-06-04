package less.green.openpudo.rest.dto;

import java.util.List;
import java.util.Map;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.rest.dto.address.Address;
import less.green.openpudo.rest.dto.geojson.Feature;
import less.green.openpudo.rest.dto.geojson.Point;
import less.green.openpudo.rest.dto.map.AutocompleteResult;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.user.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    User mapUserEntityToDto(TbUser ent);

    @Mapping(source = "ent.pudo", target = ".")
    @Mapping(source = "ent.address", target = "address")
    Pudo mapPudoEntityToDto(PudoAndAddress ent);

    List<Pudo> mapPudoEntityListToDtoList(List<PudoAndAddress> ent);

    Address mapAddressEntityToDto(TbAddress ent);

    default AutocompleteResult mapFeatureToAutocompleteResult(Feature feat) {
        if (feat == null) {
            return null;
        }
        AutocompleteResult ret = new AutocompleteResult();
        Map<String, String> properties = feat.getProperties();
        ret.setLabel(properties.get("label"));
        ret.setResultId(properties.get("gid"));
        Point geometry = feat.getGeometry();
        ret.setLat(geometry.getCoordinates().get(1));
        ret.setLon(geometry.getCoordinates().get(0));
        return ret;
    }

    List<AutocompleteResult> mapFeatureToAutocompleteResult(List<Feature> feat);

    default void mapFeatureToExistingAddressEntity(Feature feat, TbAddress ent) {
        if (feat == null) {
            return;
        }
        Map<String, String> properties = feat.getProperties();
        ent.setLabel(properties.get("label"));
        ent.setStreet(properties.get("street"));
        ent.setStreetNum(properties.get("housenumber"));
        ent.setZipCode(properties.get("postalcode"));
        ent.setCity(properties.get("locality"));
        ent.setProvince(properties.get("region"));
        ent.setCountry(properties.get("country"));
        Point geometry = feat.getGeometry();
        ent.setLat(geometry.getCoordinates().get(1));
        ent.setLon(geometry.getCoordinates().get(0));
    }
}
