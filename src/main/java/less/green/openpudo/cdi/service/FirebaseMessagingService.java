package less.green.openpudo.cdi.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import io.quarkus.runtime.Startup;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Path;
import javax.annotation.PostConstruct;
import javax.enterprise.context.ApplicationScoped;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
@Startup
@Log4j2
public class FirebaseMessagingService {

    @ConfigProperty(name = "firebase.config.path")
    Path firebaseConfigPath;

    @PostConstruct
    void init() throws IOException {
        // hot reload quirk
        try {
            FirebaseApp.getInstance();
        } catch (IllegalStateException ex) {
            try (FileInputStream fis = new FileInputStream(firebaseConfigPath.toFile())) {
                FirebaseOptions options = FirebaseOptions.builder().setCredentials(GoogleCredentials.fromStream(fis)).build();
                FirebaseApp.initializeApp(options);
            }
        }
    }

    public String sendNotification(Message message) throws FirebaseMessagingException {
        String response = FirebaseMessaging.getInstance().send(message);
        return response;
    }

}
