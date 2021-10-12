package less.green.openpudo.rest.resource;

import java.util.UUID;
import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.HeaderParam;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.persistence.model.TbExternalFile;
import less.green.openpudo.persistence.service.ExternalFileService;
import less.green.openpudo.rest.config.BinaryAPI;
import less.green.openpudo.rest.config.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import less.green.openpudo.rest.dto.DtoMapper;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

@RequestScoped
@Path("/file")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class ExternalFileResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    ExternalFileService externalFileService;

    @Inject
    DtoMapper dtoMapper;

    @GET
    @Path("/{externalFileId}")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get external file, simulating a static resource server by an http server")
    public Response getExternalFile(@PathParam(value = "externalFileId") UUID externalFileId, @HeaderParam("Application-Language") String language) {
        try {
            Pair<TbExternalFile, byte[]> ext = externalFileService.getExternalFile(externalFileId);
            if (ext == null) {
                return Response.status(Response.Status.NOT_FOUND).build();
            }
            return Response.ok(ext.getValue1()).header("Content-Type", ext.getValue0().getMimeType()).build();
        } catch (RuntimeException ex) {
            log.error("[{}] {}", context.getExecutionId(), ExceptionUtils.getCompactStackTrace(ex));
            throw new ApiException(ApiReturnCodes.SERVICE_UNAVAILABLE, localizationService.getMessage(language, "error.service_unavailable"));
        }
    }

}
