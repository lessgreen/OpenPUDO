package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.PackageService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.MultipartUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.pack.ChangePackageStatusRequest;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageResponse;
import less.green.openpudo.rest.dto.scalar.UUIDResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.security.SecurityRequirement;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import java.io.IOException;
import java.util.UUID;

import static less.green.openpudo.common.MultipartUtils.ALLOWED_IMAGE_MIME_TYPES;

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

    @GET
    @Path("/by-qrcode/{shareLink}")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Get info and event log for package by generated QRCode")
    public PackageResponse getPackageByShareLink(@PathParam(value = "shareLink") String shareLink) {
        Package ret = packageService.getPackageByShareLink(shareLink);
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

    @PUT
    @Path("/{packageId}/picture")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Update picture for for package with provided packageId")
    public UUIDResponse updatePackagePicture(@PathParam(value = "packageId") Long packageId, MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = MultipartUtils.readUploadedFile(req);
        } catch (IOException ex) {
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(context.getLanguage(), "error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_mandatory_field", "multipart name"));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "mimeType"));
        }

        UUID ret = packageService.updatePackagePicture(packageId, uploadedFile.getValue0(), uploadedFile.getValue1());
        return new UUIDResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/{packageId}/notified")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Signal that the user has received the delivery notification of a package")
    public PackageResponse notifiedPackage(@PathParam(value = "packageId") Long packageId) {
        Package ret = packageService.notifiedPackage(packageId);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/{packageId}/collected")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Signal that the user has collected the package")
    public PackageResponse collectedPackage(@PathParam(value = "packageId") Long packageId, ChangePackageStatusRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Package ret = packageService.collectedPackage(packageId, req);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

    @POST
    @Path("/{packageId}/accepted")
    @SecurityRequirement(name = "JWT")
    @Operation(summary = "Signal that the user confirms the package collection")
    public PackageResponse acceptedPackage(@PathParam(value = "packageId") Long packageId, ChangePackageStatusRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.empty_request"));
        }

        Package ret = packageService.acceptedPackage(packageId, req);
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
