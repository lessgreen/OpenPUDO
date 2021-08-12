package less.green.openpudo.cdi.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import io.quarkus.runtime.Startup;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.util.Map;
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

    public String sendNotification(String token, String title, String body, Map<String, String> data) {
        Notification notification = Notification.builder().setTitle(title).setBody(body).build();
        Message.Builder mb = Message.builder();
        mb.setToken(token);
        mb.setNotification(notification);
        if (data != null && !data.isEmpty()) {
            mb.putAllData(data);
        }
        Message message = mb.build();
        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (FirebaseMessagingException ex) {
            log.error("Firebase error: {}, {}", ex.getMessagingErrorCode(), ex.getMessage());
            return null;
        }
    }

}
