package less.green.openpudo.rest.resource;

import com.google.zxing.WriterException;
import io.quarkus.runtime.configuration.ProfileManager;
import less.green.openpudo.business.service.ShareService;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.LocalizationService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.Encoders;
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
import java.net.URI;
import java.net.URISyntaxException;
import java.util.UUID;

import static less.green.openpudo.common.StringUtils.isEmpty;

@RequestScoped
@Path("/share")
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
    @Produces(MediaType.TEXT_HTML)
    @PublicAPI
    @BinaryAPI
    @Operation(summary = "Get package share html page, simulating a static resource served by an http server")
    public Response getSharePage(@PathParam(value = "shareLink") String shareLink) {
        return shareService.getSharePage(shareLink);
    }

    @GET
    @Path("/qrcode/{shareLink}")
    @Produces("image/png")
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

    @GET
    @Path("/redirect/{channel}")
    @PublicAPI
    @Operation(summary = "Get QRCode of the provided share link, simulating a static resource served by an http server")
    public Response redirect(@PathParam(value = "channel") String channel) throws URISyntaxException {
        // avoid persisting incomplete links fetched by messaging apps or social networks
        if (!isEmpty(channel) && channel.length() == 4) {
            shareService.saveRedirectLog(channel);
        }
        if (!isEmpty(context.getUserAgent()) && (context.getUserAgent().toLowerCase().contains("iphone") || context.getUserAgent().toLowerCase().contains("ipad"))) {
            return Response.temporaryRedirect(new URI("https://www.quigreen.it/app-ios/")).build();
        } else if (!isEmpty(context.getUserAgent()) && context.getUserAgent().toLowerCase().contains("android")) {
            return Response.temporaryRedirect(new URI("https://www.quigreen.it/app-android/")).build();
        }
        return Response.temporaryRedirect(new URI("https://www.quigreen.it/")).build();
    }

    @GET
    @Path("/link/{linkId}")
    @PublicAPI
    @Operation(summary = "Handle Firebase Dynamic Link request")
    public Response getDynamicLink(@PathParam(value = "linkId") UUID linkId) throws URISyntaxException {
        log.info("Context: \n{}", Encoders.dumpJsonCompactPretty(context));
        if ("dev".equals(ProfileManager.getActiveProfile()) || (!isEmpty(context.getUserAgent()) && context.getUserAgent().startsWith("OpenPudo"))) {
            return shareService.getDynamicLink(linkId);
        }
        return Response.temporaryRedirect(new URI("https://www.quigreen.it/")).build();
    }

}
