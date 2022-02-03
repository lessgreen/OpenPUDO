package less.green.openpudo.business.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import less.green.openpudo.business.dao.PackageDao;
import less.green.openpudo.business.model.TbPackage;
import less.green.openpudo.business.model.TbPackageEvent;
import less.green.openpudo.cdi.service.CryptoService;
import less.green.openpudo.common.dto.tuple.Pair;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.imageio.ImageIO;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class ShareService {

    @Inject
    CryptoService cryptoService;

    @Inject
    PackageDao packageDao;

    public Response getSharePage(String shareLink) throws IOException {
        Long packageId = cryptoService.hashidDecodeLong(shareLink);
        if (packageId == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        Pair<TbPackage, List<TbPackageEvent>> rs = packageDao.getPackage(packageId);
        if (rs == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        String html;
        try (InputStream is = ShareService.class.getResourceAsStream("/html/package.html")) {
            if (is == null) {
                return Response.serverError().build();
            }
            html = new String(is.readAllBytes(), StandardCharsets.UTF_8);
        }

        String title = "Pacco pronto per il ritiro";
        String description = "Condividi questo link per far ritirare il pacco " + cryptoService.hashidEncodeShort(rs.getValue0().getPackageId()) + " ad un amico";
        String url = "https://api-dev.quigreen.it/api/v2/share/" + shareLink;
        String qrcodeUrl = "/api/v2/share/qrcode/" + shareLink;

        html = html.replace("XXX_TITLE_XXX", title);
        html = html.replace("XXX_DESCRIPTION_XXX", description);
        html = html.replace("XXX_URL_XXX", url);
        html = html.replace("XXX_QRCODE_URL_XXX", qrcodeUrl);

        return Response.ok(html).header("Content-Type", "text/html; charset=UTF-8").build();
    }

    public Response getQRCode(String shareLink, int size) throws WriterException, IOException {
        Long packageId = cryptoService.hashidDecodeLong(shareLink);
        if (packageId == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }
        TbPackage rs = packageDao.get(packageId);
        if (rs == null) {
            return Response.status(Response.Status.NOT_FOUND).build();
        }

        QRCodeWriter writer = new QRCodeWriter();
        BitMatrix bitMatrix = writer.encode(shareLink, BarcodeFormat.QR_CODE, size, size);
        BufferedImage image = MatrixToImageWriter.toBufferedImage(bitMatrix);
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(image, "png", baos);
        return Response.ok(baos.toByteArray()).header("Content-Type", "image/png").build();
    }

}
