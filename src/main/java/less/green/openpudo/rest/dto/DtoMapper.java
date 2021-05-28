package less.green.openpudo.rest.dto;

import java.util.List;
import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbPudo;
import less.green.openpudo.persistence.model.TbUser;
import less.green.openpudo.rest.dto.address.Address;
import less.green.openpudo.rest.dto.pudo.Pudo;
import less.green.openpudo.rest.dto.user.User;
import org.mapstruct.Mapper;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    User mapUserEntityToDto(TbUser ent);

    Pudo mapPudoEntityToDto(TbPudo ent);

    List<Pudo> mapPudoEntityListToDtoList(List<TbPudo> ent);

    Address mapAddressEntityToDto(TbAddress ent);

}
