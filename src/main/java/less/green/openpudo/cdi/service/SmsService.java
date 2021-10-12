package less.green.openpudo.cdi.service;

import com.fasterxml.jackson.databind.node.ObjectNode;
import io.quarkus.runtime.Startup;
import javax.enterprise.context.ApplicationScoped;
import kong.unirest.Unirest;
import kong.unirest.UnirestException;
import less.green.openpudo.common.Encoders;
import static less.green.openpudo.common.Encoders.OBJECT_MAPPER;
import lombok.extern.log4j.Log4j2;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
@Startup
@Log4j2
public class SmsService {

    private static final String MAILJET_SMS_API_URL = "https://api.mailjet.com/v4/sms-send";

    @ConfigProperty(name = "mailjet.sms.api.token")
    String apiToken;

    @ConfigProperty(name = "mailjet.sms.from.name")
    String fromName;

    public void sendSms(String toNumber, String text) {
        ObjectNode body = createBody(toNumber, text);
        try {
            var req = Unirest.post(MAILJET_SMS_API_URL)
                    .header("Authorization", "Bearer " + apiToken)
                    .header("Content-Type", "application/json")
                    .body(Encoders.writeValueAsStringSafe(body));
            var res = req.asJson();
            if (res == null || res.getBody() == null) {
                throw new RuntimeException("Sms service returned empty response");
            }
            if (res.getStatus() != 200) {
                throw new RuntimeException("Sms service returned: " + res.getStatus() + " " + res.getStatusText() + " - " + res.getBody().toString());
            }
        } catch (UnirestException ex) {
            throw new RuntimeException("Sms service unavailable", ex);
        }
    }

    private ObjectNode createBody(String toNumber, String text) {
        var body = OBJECT_MAPPER.createObjectNode();
        body.set("From", OBJECT_MAPPER.valueToTree(fromName));
        body.set("To", OBJECT_MAPPER.valueToTree(toNumber));
        body.set("Text", OBJECT_MAPPER.valueToTree(text));
        return body;
    }

}
