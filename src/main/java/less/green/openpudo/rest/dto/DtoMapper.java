package less.green.openpudo.rest.dto;

import java.util.List;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.persistence.projection.PudoAndAddress;
import less.green.openpudo.rest.dto.address.Address;
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
}
