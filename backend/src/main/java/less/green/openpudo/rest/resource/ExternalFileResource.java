package less.green.openpudo.rest.resource;

import com.fasterxml.jackson.databind.JsonNode;
import less.green.openpudo.business.service.ExternalFileService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.dto.scalar.JsonResponse;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;
import java.util.UUID;

@RequestScoped
@Path("/file")
@Produces(value = MediaType.APPLICATION_JSON)
@Consumes(value = MediaType.APPLICATION_JSON)
@Log4j2
public class ExternalFileResource {

    @Inject
    ExecutionContext context;

    @Inject
    ExternalFileService externalFileService;

    @GET
    @Path("/{fileId}")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get external file, simulating a static resource served by an http server")
    public Response getExternalFile(@PathParam(value = "fileId") UUID externalFileId) {
        return externalFileService.getExternalFile(externalFileId);
    }

    @GET
    @Path("/user-data/{userDataId}")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Download deleted user data, simulating a static resource served by an http server")
    public Response getDeletedUserData(@PathParam(value = "userDataId") UUID userDataId) {
        return externalFileService.getDeletedUserData(userDataId);
    }

    @GET
    @Path("/localization")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get app localization JSON content")
    public JsonResponse getLocalization(@QueryParam(value = "lang") String lang) throws IOException {
        JsonNode ret = externalFileService.getLocalization(lang);
        return new JsonResponse(context.getExecutionId(), ApiReturnCodes.OK, ret);
    }

}
