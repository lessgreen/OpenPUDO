package less.green.openpudo.rest.resource;

import less.green.openpudo.business.service.ExternalFileService;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.util.UUID;

@RequestScoped
@Path("/file")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class ExternalFileResource {

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

}
