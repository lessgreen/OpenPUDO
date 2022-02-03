package less.green.openpudo.rest.resource;

import com.google.zxing.WriterException;
import less.green.openpudo.business.service.ShareService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.rest.config.annotation.BinaryAPI;
import less.green.openpudo.rest.config.annotation.PublicAPI;
import less.green.openpudo.rest.config.exception.ApiException;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.parameters.Parameter;

import javax.enterprise.context.RequestScoped;
import javax.inject.Inject;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.io.IOException;

@RequestScoped
@Path("/share")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
@Log4j2
public class ShareResource {

    @Inject
    ExecutionContext context;

    @Inject
    LocalizationService localizationService;

    @Inject
    ShareService shareService;

    @GET
    @Path("/{shareLink}")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get package share html page, simulating a static resource served by an http server")
    public Response getSharePage(@PathParam(value = "shareLink") String shareLink) throws IOException {
        return shareService.getSharePage(shareLink);
    }

    @GET
    @Path("/qrcode/{shareLink}")
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get QRCode of the provided share link, simulating a static resource served by an http server")
    public Response getQRCode(@PathParam(value = "shareLink") String shareLink,
                              @Parameter(description = "Desired size in pixel, between 100 and 1000") @DefaultValue("500") @QueryParam("size") int size) throws WriterException, IOException {
        // sanitize input
        if (size < 100 || size > 1000) {
            throw new ApiException(ApiReturnCodes.BAD_REQUEST, localizationService.getMessage(context.getLanguage(), "error.invalid_field", "size"));
        }
        return shareService.getQRCode(shareLink, size);
    }

}
