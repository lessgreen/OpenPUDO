package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.PackageService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

@RequestScoped
@Path("/package")
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

    @GET
    @Path("/{packageId}")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get info and event log for package with provided packageId")
    public PackageResponse getPackage(@PathParam(value = "packageId") Long packageId) {
        Package ret = packageService.getPackage(packageId);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Signal the delivery of a package for current PUDO")
    public PackageResponse deliveredPackage(DeliveredPackageRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        } else if (req.getUserId() == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "userId"));
        }

        Package ret = packageService.deliveredPackage(req);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
