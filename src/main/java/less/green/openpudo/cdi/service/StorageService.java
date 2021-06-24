package less.green.openpudo.cdi.service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;
import javax.enterprise.context.ApplicationScoped;
import static less.green.openpudo.common.Encoders.BASE64_DECODER;
import static less.green.openpudo.common.Encoders.BASE64_ENCODER;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
@Log4j2
public class StorageService {

    @ConfigProperty(name = "storage.path")
    Path storagePath;

    public String readFileBase64(UUID externalFileId) {
        Path filePath = getNestedFilePath(externalFileId);
        try {
            if (Files.exists(filePath) && Files.isRegularFile(filePath)) {
                byte[] bytes = Files.readAllBytes(filePath);
                return BASE64_ENCODER.encodeToString(bytes);
            } else {
                return null;
            }
        } catch (IOException ex) {
            throw new RuntimeException("Error while accessing storage area", ex);
        }
    }

    public void saveFileBase64(UUID externalFileId, String contentBase64) {
        Path filePath = getNestedFilePath(externalFileId);
        Path parentDirPath = filePath.getParent();
        try {
            if (!Files.exists(parentDirPath)) {
                Files.createDirectories(parentDirPath);
            }
            byte[] bytes = BASE64_DECODER.decode(contentBase64);
            Files.write(filePath, bytes);
        } catch (IOException ex) {
            throw new RuntimeException("Error while accessing storage area", ex);
        }
    }

    public void deleteFileBase64(UUID externalFileId) {
        Path filePath = getNestedFilePath(externalFileId);
        try {
            if (Files.exists(filePath) && Files.isRegularFile(filePath)) {
                Files.delete(filePath);
            } else {
                log.error("Required deletion of not existent external file: {}", externalFileId);
            }
        } catch (IOException ex) {
            throw new RuntimeException("Error while accessing storage area", ex);
        }
    }

    private Path getNestedFilePath(UUID externalFileId) {
        String firstLevelDir = externalFileId.toString().substring(0, 2);
        String secondLevelDir = externalFileId.toString().substring(2, 4);
        return storagePath.resolve(firstLevelDir).resolve(secondLevelDir).resolve(externalFileId.toString());
    }

}
