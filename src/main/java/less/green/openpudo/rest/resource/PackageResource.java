package less.green.openpudo.rest.resource;

import java.io.IOException;
import java.util.List;
import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.MediaType;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.MultipartUtils;
import static less.green.openpudo.common.MultipartUtils.ALLOWED_IMAGE_MIME_TYPES;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.dao.usertype.PackageStatus;
import less.green.openpudo.persistence.model.TbPackage;
import less.green.openpudo.persistence.model.TbPackageEvent;
import less.green.openpudo.persistence.service.PackageService;
import less.green.openpudo.persistence.service.PudoService;
import less.green.openpudo.rest.config.BinaryAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.BaseResponse;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pack.ChangePackageStatusRequest;
import less.green.openpudo.rest.dto.pack.DeliveredPackageRequest;
import less.green.openpudo.rest.dto.pack.PackageListResponse;
import less.green.openpudo.rest.dto.pack.PackageResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;
import org.jboss.resteasy.plugins.providers.multipart.MultipartFormDataInput;

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

    @PUT
    @Path("/picture/{externalFileId}")
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    @BinaryAPI
    @Operation(summary = "Upload delivery picture for incoming package",
            description = "This API can be called before creating the package itself, to allow async upload, the UUID of the image must be client generated")
    public BaseResponse uploadPackagePicture(@PathParam(value = "externalFileId") UUID externalFileId, MultipartFormDataInput req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        }

        Pair<String, byte[]> uploadedFile;
        try {
            uploadedFile = MultipartUtils.readUploadedFile(req);
        } catch (IOException ex) {
            log.error(ex.getMessage());
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }

        // more sanitizing
        if (uploadedFile == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "multipart name"));
        }
        if (!ALLOWED_IMAGE_MIME_TYPES.contains(uploadedFile.getValue0())) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "mimeType"));
        }

        // checking permission
        // since we still know nothing about the package, operation is allowed if the current user is a pudo owner
        boolean pudoOwner = pudoService.isPudoOwner(context.getUserId());
        if (!pudoOwner) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }

        try {
            packageService.uploadPackagePicture(externalFileId, uploadedFile.getValue0(), uploadedFile.getValue1());
            log.info("[{}] Uploaded package picture: {}", context.getExecutionId(), externalFileId);
            return new BaseResponse(context.getExecutionId(), ApiReturnCodes.OK);
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage("error.service_unavailable"));
        }
    }

    @POST
    @Path("/")
    @Operation(summary = "Signal the delivery of a package for current PUDO")
    public PackageResponse deliveredPackage(DeliveredPackageRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        } else if (req.getUserId() == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_mandatory_field", "userId"));
        }

        // checking permission
        // operation is allowed if the current user is a pudo owner and there is a customer relationship
        Long pudoId = pudoService.getPudoIdByOwner(context.getUserId());
        if (pudoId == null) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.user.not_pudo_owner"));
        }
        boolean pudoCustomer = pudoService.isPudoCustomer(req.getUserId(), pudoId);
        if (!pudoCustomer) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.package.customer_not_in_list"));
        }

        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.deliveredPackage(pudoId, req);
        log.info("[{}] Created package: {} in PUDO: {}, for user: {}", context.getExecutionId(), pack.getValue0().getPackageId(), pudoId, req.getUserId());
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @POST
    @Path("/{packageId}/notified")
    @Operation(summary = "Signal that the user has received the delivery notification of a package")
    public PackageResponse notifiedPackage(@PathParam(value = "packageId") Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.getPackageById(packageId);
        if (pack == null) {
            throw new ApiException(ApiReturnCodes.RESOURCE_NOT_FOUND, localizationService.getMessage("error.resource_not_exists"));
        }

        // checking permission
        // operation is allowed if the current user is the package recipient
        if (!pack.getValue0().getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
        }

        // if package is in expected state we make the transition, otherwise we silently skip it and return the current state
        if (pack.getValue1().get(0).getPackageStatus() == PackageStatus.NOTIFY_SENT) {
            pack = packageService.notifiedPackage(packageId);
            log.info("[{}] Package: {} -> {}", context.getExecutionId(), pack.getValue0().getPackageId(), pack.getValue1().get(0).getPackageStatus());
        }
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @POST
    @Path("/{packageId}/collected")
    @Operation(summary = "Signal that the user has collected the package")
    public PackageResponse collectedPackage(@PathParam(value = "packageId") Long packageId, ChangePackageStatusRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        }

        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.getPackageById(packageId);
        if (pack == null) {
            throw new ApiException(ApiReturnCodes.RESOURCE_NOT_FOUND, localizationService.getMessage("error.error.resource_not_exists"));
        }

        // checking permission
        // operation is allowed if the current user is the package pudo owner
        Long pudoId = pudoService.getPudoIdByOwner(context.getUserId());
        if (!pack.getValue0().getPudoId().equals(pudoId)) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
        }

        // operation is allowed if the package is in those states
        if (pack.getValue1().get(0).getPackageStatus() != PackageStatus.DELIVERED
                && pack.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFY_SENT
                && pack.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFIED) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage("error.package.illegal_state"));
        }

        pack = packageService.collectedPackage(packageId, req);
        log.info("[{}] Package: {} -> {}", context.getExecutionId(), pack.getValue0().getPackageId(), pack.getValue1().get(0).getPackageStatus());
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @POST
    @Path("/{packageId}/accepted")
    @Operation(summary = "Signal that the user confirms the package collection")
    public PackageResponse acceptedPackage(@PathParam(value = "packageId") Long packageId, ChangePackageStatusRequest req) {
        // sanitize input
        if (req == null) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.empty_request"));
        }

        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.getPackageById(packageId);
        if (pack == null) {
            throw new ApiException(ApiReturnCodes.RESOURCE_NOT_FOUND, localizationService.getMessage("error.resource_not_exists"));
        }

        // checking permission
        // operation is allowed if the current user is the package recipient
        if (!pack.getValue0().getUserId().equals(context.getUserId())) {
            throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
        }

        // operation is allowed if the package is in those states
        if (pack.getValue1().get(0).getPackageStatus() != PackageStatus.DELIVERED
                && pack.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFY_SENT
                && pack.getValue1().get(0).getPackageStatus() != PackageStatus.NOTIFIED
                && pack.getValue1().get(0).getPackageStatus() != PackageStatus.COLLECTED) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage("error.package.illegal_state"));
        }

        pack = packageService.acceptedPackage(packageId, req);
        log.info("[{}] Package: {} -> {}", context.getExecutionId(), pack.getValue0().getPackageId(), pack.getValue1().get(0).getPackageStatus());
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @GET
    @Path("/{packageId}")
    @Operation(summary = "Get info and event log for package with provided packageId")
    public PackageResponse getPackageById(@PathParam(value = "packageId") Long packageId) {
        Pair<TbPackage, List<TbPackageEvent>> pack = packageService.getPackageById(packageId);
        if (pack != null) {
            // checking permission
            // operation is allowed if the current user is the package pudo owner or the package recipient
            Long pudoId = pudoService.getPudoIdByOwner(context.getUserId());
            if (!pack.getValue0().getPudoId().equals(pudoId) && !pack.getValue0().getUserId().equals(context.getUserId())) {
                throw new ApiException(ApiReturnCodes.FORBIDDEN, localizationService.getMessage("error.forbidden"));
            }
        }
        return new PackageResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityToDto(pack));
    }

    @GET
    @Path("/")
    @Operation(summary = "Get package list for current user, with optional query parameters",
            description = "If called without parameters, this API return the summary of all packages in \"open\" state for the current user, behaving differently if the caller is a user or a PUDO.\n\n"
            + "Parameters can be used to perform an historical search, and pagination will be used only in this mode.")
    public PackageListResponse getPackageList(
            @Parameter(description = "Historical search", required = false) @DefaultValue("false") @QueryParam("history") boolean history,
            @Parameter(description = "Pagination limit", required = false) @DefaultValue("20") @QueryParam("limit") int limit,
            @Parameter(description = "Pagination offset", required = false) @DefaultValue("0") @QueryParam("offset") int offset) {
        // sanitize input
        if (limit < 1) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "limit"));
        }
        if (offset < 0) {
            throw new ApiException(ApiReturnCodes.INVALID_REQUEST, localizationService.getMessage("error.invalid_field", "offset"));
        }

        List<Pair<TbPackage, List<TbPackageEvent>>> packs = packageService.getPackageList(context.getUserId(), history, limit, offset);
        return new PackageListResponse(context.getExecutionId(), ApiReturnCodes.OK, dtoMapper.mapPackageEntityListToDto(packs));
    }

}
