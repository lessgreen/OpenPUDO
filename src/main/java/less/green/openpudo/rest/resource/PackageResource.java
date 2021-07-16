package less.green.openpudo.rest.resource;

import java.util.List;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.persistence.service.PackageService;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.map.pack.PackageRequest;
import less.green.openpudo.rest.dto.map.pack.PackageResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

@RequestScoped
@Path("/packages")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class PackageResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    PackageService packageService;
    @Inject
    PudoService pudoService;

    @Inject
    DtoMapper dtoMapper;

    @GET
    @Path("/{packageId}")
    @Operation(summary = "Get info and event log for package with provided packageId")
    public PackageResponse getPackageById(@PathParam(value = "packageId") Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.getPackageById(packageId);
        if (pack != null) {
            // checking permission
            // resource is accessible if the current user is the pudo owner or the package recipient
            Long pudoId = pudoService.getPudoIdByOwner(context.getUserId());
            if (!pack.getValue0().getPudoId().equals(pudoId) && !pack.getValue0().getUserId().equals(context.getUserId())) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
            }
        }
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @POST
    @Path("/")
    @Operation(summary = "Signal the delivery of a package for current PUDO")
    public PackageResponse deliveredPackage(PackageRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (req.getUserId() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "userId"));
        }

        // checking permission
        Long pudoId = pudoService.getPudoIdByOwner(context.getUserId());
        if (pudoId == null) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }
        boolean pudoCustomer = pudoService.isPudoCustomer(req.getUserId(), pudoId);
        if (!pudoCustomer) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.package.customer_not_in_list"));
        }

        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.deliveredPackage(pudoId, req);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

}
