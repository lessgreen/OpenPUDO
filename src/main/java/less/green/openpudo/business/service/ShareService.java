package less.green.openpudo.business.service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import less.green.openpudo.business.dao.PackageDao;
import less.green.openpudo.business.model.TbPackage;
import less.green.openpudo.cdi.service.CryptoService;
import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.RequestScoped;
import javax.imageio.ImageIO;
import javax.inject.Inject;
import javax.transaction.Transactional;
import javax.ws.rs.core.Response;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

@RequestScoped
@Transactional(Transactional.TxType.REQUIRED)
@Log4j2
public class ShareService {

    @Inject
    CryptoService cryptoService;

    @Inject
    PackageDao packageDao;

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
