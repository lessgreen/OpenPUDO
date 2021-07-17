package less.green.openpudo.cdi.service;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.BatchResponse;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.MulticastMessage;
import com.google.firebase.messaging.Notification;
import io.quarkus.runtime.Startup;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.Path;
import java.util.List;
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

    public BatchResponse sendNotification(List<String> tokens, String title, String body, Map<String, String> data) {
        Notification notification = Notification.builder().setTitle(title).setBody(body).build();
        MulticastMessage.Builder mb = MulticastMessage.builder();
        mb.addAllTokens(tokens);
        mb.setNotification(notification);
        if (data != null && !data.isEmpty()) {
            mb.putAllData(data);
        }
        MulticastMessage message = mb.build();
        try {
            BatchResponse resp = FirebaseMessaging.getInstance().sendMulticast(message);
            return resp;
        } catch (FirebaseMessagingException ex) {
            log.error("Firebase error: {}, {}", ex.getMessagingErrorCode(), ex.getMessage());
            return null;
        }
    }

}
