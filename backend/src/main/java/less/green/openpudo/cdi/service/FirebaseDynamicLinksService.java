package less.green.openpudo.cdi.service;

import com.fasterxml.jackson.databind.node.ObjectNode;
import io.quarkus.runtime.Startup;
import kong.unirest.Unirest;
import kong.unirest.UnirestException;
import less.green.openpudo.common.Encoders;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

import javax.enterprise.context.ApplicationScoped;
import java.util.UUID;

import static less.green.openpudo.common.Encoders.OBJECT_MAPPER;

@ApplicationScoped
@Startup
@Log4j2
public class FirebaseDynamicLinksService {

    private static final String FIREBASE_DYNAMIC_LINKS_API = "https://firebasedynamiclinks.googleapis.com/v1/shortLinks";

    @ConfigProperty(name = "firebase.links.api.key")
    String apiKey;

    @ConfigProperty(name = "firebase.links.domain")
    String domain;

    @ConfigProperty(name = "firebase.android.apn")
    String apn;

    @ConfigProperty(name = "firebase.ios.ibi")
    String ibi;

    @ConfigProperty(name = "firebase.ios.isi")
    String isi;

    @ConfigProperty(name = "app.base.url")
    String appBaseUrl;

    public String generateDynamicLink(UUID linkId) {
        ObjectNode body = createBody(linkId);
        try {
            var req = Unirest.post(FIREBASE_DYNAMIC_LINKS_API)
                    .queryString("key", apiKey)
                    .header("Content-Type", "application/json")
                    .body(Encoders.dumpJson(body));
            var res = req.asJson();
            if (res == null || res.getBody() == null) {
                throw new RuntimeException("Sms service returned empty response");
            }
            if (res.getStatus() != 200) {
                throw new RuntimeException("Sms service returned: " + res.getStatus() + " " + res.getStatusText() + " - " + res.getBody().toString());
            }
            return res.getBody().getObject().getString("shortLink");
        } catch (UnirestException ex) {
            throw new RuntimeException("Firebase dynamic links service unavailable", ex);
        }
    }

    public ObjectNode createBody(UUID linkId) {
        var body = OBJECT_MAPPER.createObjectNode();
        var dynamicLinkInfo = OBJECT_MAPPER.createObjectNode();
        body.set("dynamicLinkInfo", dynamicLinkInfo);
        dynamicLinkInfo.set("domainUriPrefix", OBJECT_MAPPER.valueToTree(domain));
        dynamicLinkInfo.set("link", OBJECT_MAPPER.valueToTree(appBaseUrl + "/api/v2/share/link/" + linkId.toString()));
        var androidInfo = OBJECT_MAPPER.createObjectNode();
        dynamicLinkInfo.set("androidInfo", androidInfo);
        androidInfo.set("androidPackageName", OBJECT_MAPPER.valueToTree(apn));
        var iosInfo = OBJECT_MAPPER.createObjectNode();
        dynamicLinkInfo.set("iosInfo", iosInfo);
        iosInfo.set("iosBundleId", OBJECT_MAPPER.valueToTree(ibi));
        iosInfo.set("iosAppStoreId", OBJECT_MAPPER.valueToTree(isi));
        var navigationInfo = OBJECT_MAPPER.createObjectNode();
        dynamicLinkInfo.set("navigationInfo", navigationInfo);
        navigationInfo.set("enableForcedRedirect", OBJECT_MAPPER.valueToTree(true));
        var suffix = OBJECT_MAPPER.createObjectNode();
        body.set("suffix", suffix);
        suffix.set("option", OBJECT_MAPPER.valueToTree("UNGUESSABLE"));
        log.info(body);
        return body;
    }

}
