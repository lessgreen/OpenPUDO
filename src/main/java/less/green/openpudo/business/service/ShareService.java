package less.green.openpudo.business.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import io.quarkus.qute.Location;
import io.quarkus.qute.Template;
import io.quarkus.qute.TemplateInstance;
import less.green.openpudo.business.dao.PackageDao;
import less.green.openpudo.business.model.TbPackage;
import less.green.openpudo.business.model.TbPackageEvent;
import less.green.openpudo.business.model.usertype.PackageStatus;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.common.dto.tuple.Pair;
import less.green.openpudo.common.dto.tuple.Quartet;
import less.green.openpudo.rest.dto.DtoMapper;
import less.green.openpudo.rest.dto.pack.Package;
import less.green.openpudo.rest.dto.pack.PackageEvent;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.imageio.ImageIO;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class ShareService {

    @Inject
    CryptoService cryptoService;

    @Inject
    PackageService packageService;

    @Inject
    PackageDao packageDao;

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

        List<PackageEvent> events = rs.getValue1().stream().map(i -> dtoMapper.mapPackageEventEntityToDto(new Pair<>(i, packageService.getPackageStatusMessage(i.getPackageStatus(), "it")))).collect(Collectors.toList());
        Package pack = dtoMapper.mapPackageEntityToDto(new Quartet<>(rs.getValue0(), events, cryptoService.hashidEncodeShort(packageId), cryptoService.hashidEncodeLong(packageId)));
        TemplateInstance templateInstance = packageTemplate.data("package", pack);
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
        BitMatrix bitMatrix = writer.encode(shareLink, BarcodeFormat.QR_CODE, size, size);
        BufferedImage image = MatrixToImageWriter.toBufferedImage(bitMatrix);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        return Response.ok(baos.toByteArray()).build();
    }

}
