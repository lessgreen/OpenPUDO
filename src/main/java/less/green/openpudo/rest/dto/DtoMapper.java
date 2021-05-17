package less.green.openpudo.rest.dto;

import less.green.openpudo.persistence.model.TbAddress;
import less.green.openpudo.persistence.model.TbUserProfile;
import org.mapstruct.Mapper;

@Mapper(componentModel = "cdi")
public interface DtoMapper {

    UserProfile mapUserProfileEntityToDto(TbUserProfile ent);

    Address mapAddressEntityToDto(TbAddress ent);

}
