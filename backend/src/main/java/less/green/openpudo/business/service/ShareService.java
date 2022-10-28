package less.green.openpudo.business.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;
import io.quarkus.qute.Location;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import less.green.openpudo.business.dao.DynamicLinkDao;
import less.green.openpudo.business.dao.PackageDao;
import less.green.openpudo.business.dao.RedirectLogDao;
import less.green.openpudo.business.model.TbDynamicLink;
import less.green.openpudo.business.model.TbPackage;
import less.green.openpudo.business.model.TbPackageEvent;
import less.green.openpudo.business.model.TbRedirectLog;
import less.green.openpudo.business.model.usertype.DynamicLinkRoute;
import less.green.openpudo.business.model.usertype.PackageStatus;
import less.green.openpudo.cdi.ExecutionContext;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.cdi.service.JwtService;
import less.green.openpudo.common.ApiReturnCodes;
import less.green.openpudo.common.Encoders;
import less.green.openpudo.common.ExceptionUtils;
import less.green.openpudo.common.dto.jwt.JwtPrivateClaims;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.link.DynamicLink;
import less.green.openpudo.rest.dto.link.DynamicLinkEnrollProspectData;
import less.green.openpudo.rest.dto.link.DynamicLinkResponse;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageEvent;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.RequestScoped;
import javax.imageio.ImageIO;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.time.Instant;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

import static less.green.openpudo.common.StringUtils.sanitizeString;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class ShareService {

    @ConfigProperty(name = "app.base.url")
    String appBaseUrl;

    @Inject
    ExecutionContext context;

    @Inject
    CryptoService cryptoService;
    @Inject
    JwtService jwtService;

    @Inject
    PackageService packageService;

    @Inject
    DynamicLinkDao dynamicLinkDao;
    @Inject
    PackageDao packageDao;
    @Inject
    RedirectLogDao redirectLogDao;

    @Inject
    DtoMapper dtoMapper;

    @Location("package")
    Template packageTemplate;

    public Response getSharePage(String shareLink) {
        Long packageId = cryptoService.hashidDecodeLong(shareLink);
        if (packageId == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null || !Arrays.asList(PackageStatus.DELIVERED, PackageStatus.NOTIFIED, PackageStatus.NOTIFY_SENT, PackageStatus.COLLECTED).contains(rs.getValue1().get(0).getPackageStatus())) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }

        // TODO: proper localization, forcing italian at the moment
        context.setLanguage("it");
        List<PackageEvent> events = rs.getValue1().stream().map(i -> dtoMapper.mapPackageEventDto(i, packageService.getPackageStatusMessage(i.getPackageStatus()))).collect(Collectors.toList());
        Package pack = dtoMapper.mapPackageDto(rs.getValue0(), events, cryptoService.hashidEncodeShort(packageId), cryptoService.hashidEncodeLong(packageId));
        TemplateInstance templateInstance = packageTemplate.data("package", pack, "appBaseUrl", appBaseUrl);
        return Response.ok(templateInstance.render()).build();
    }

    public Response getQRCode(String shareLink, int size) throws WriterException, IOException {
        Long packageId = cryptoService.hashidDecodeLong(shareLink);
        if (packageId == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }
        TbPackage rs = packageDao.get(packageId);
        if (rs == null) {
            return Response.status(Response.Status.NOT_FOUND).entity(Response.Status.NOT_FOUND.getReasonPhrase()).build();
        }

        QRCodeWriter writer = new QRCodeWriter();
        Map<EncodeHintType, Object> hints = Map.of(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.Q, EncodeHintType.MARGIN, 1);
        BitMatrix bitMatrix = writer.encode(shareLink, BarcodeFormat.QR_CODE, size, size, hints);
        BufferedImage image = MatrixToImageWriter.toBufferedImage(bitMatrix);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        return Response.ok(baos.toByteArray()).build();
    }

    public void saveRedirectLog(String channel) {
        try {
            TbRedirectLog tbRedirectLog = new TbRedirectLog();
            tbRedirectLog.setCreateTms(Instant.now());
            tbRedirectLog.setChannel(sanitizeString(channel));
            tbRedirectLog.setRemoteAddress(context.getRemoteAddress());
            tbRedirectLog.setUserAgent(context.getUserAgent());
            redirectLogDao.persist(tbRedirectLog);
            redirectLogDao.flush();
        } catch (Exception ex) {
            // very unlikely to have errors, but we don't want to break redirection anyway
            log.fatal("[{}] {}", context.getExecutionId(), ExceptionUtils.getCanonicalFormWithStackTrace(ex));
        }
    }

    public Response getDynamicLink(UUID dynamicLinkId) {
        TbDynamicLink ent = dynamicLinkDao.get(dynamicLinkId);
        if (ent == null || (!ent.getReusableFlag() && ent.getUsedTms() != null)) {
            return Response.ok(new DynamicLinkResponse(context.getExecutionId(), ApiReturnCodes.OK, null)).build();
        }

        if (ent.getAccessTms() == null) {
            ent.setAccessTms(Instant.now());
            dynamicLinkDao.flush();
        }

        DynamicLink ret = new DynamicLink();
        ret.setRoute(ent.getRoute());
        if (ent.getRoute() == DynamicLinkRoute.ENROLL_PROSPECT) {
            DynamicLinkEnrollProspectData data = Encoders.OBJECT_MAPPER.convertValue(ent.getData(), DynamicLinkEnrollProspectData.class);
            if (data.getPhoneNumber() != null) {
                data.setAccessTokenData(jwtService.generateGuestTokenData(new JwtPrivateClaims(data.getPhoneNumber())));
            }
            ret.setData(data);
        } else {
            throw new AssertionError("Unsupported DynamicLinkRoute: " + ent.getRoute());
        }

        return Response.ok(new DynamicLinkResponse(context.getExecutionId(), ApiReturnCodes.OK, ret)).build();
    }
}
