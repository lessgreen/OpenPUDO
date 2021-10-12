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
public class EmailService {

    @ConfigProperty(name = "mailjet.email.api.key")
    String apiKey;

    @ConfigProperty(name = "mailjet.email.secret.key")
    String secretKey;

    @ConfigProperty(name = "mailjet.email.api.url")
    String apiUrl;

    @ConfigProperty(name = "mailjet.email.from.name")
    String fromName;

    @ConfigProperty(name = "mailjet.email.from.email")
    String fromEmail;

    public void sendEmail(String toName, String toEmail, String subject, String text) {
        ObjectNode body = createBody(toName, toEmail, subject, text);
        try {
            var req = Unirest.post(apiUrl)
                    .basicAuth(apiKey, secretKey)
                    .header("Content-Type", "application/json")
                    .body(Encoders.writeValueAsStringSafe(body));
            var res = req.asJson();
            if (res == null || res.getBody() == null) {
                throw new RuntimeException("Email service returned empty response");
            }
            if (res.getStatus() != 200) {
                throw new RuntimeException("Email service returned: " + res.getStatus() + " " + res.getStatusText() + " - " + res.getBody().toString());
            }
        } catch (UnirestException ex) {
            throw new RuntimeException("Email service unavailable", ex);
        }
    }

    private ObjectNode createBody(String toName, String toEmail, String subject, String text) {
        var body = OBJECT_MAPPER.createObjectNode();
        var messages = OBJECT_MAPPER.createArrayNode();
        body.set("Messages", messages);
        var message = OBJECT_MAPPER.createObjectNode();
        messages.add(message);
        var fromAddress = OBJECT_MAPPER.createObjectNode();
        message.set("From", fromAddress);
        fromAddress.set("Email", OBJECT_MAPPER.valueToTree(fromEmail));
        fromAddress.set("Name", OBJECT_MAPPER.valueToTree(fromName));
        var toAddresses = OBJECT_MAPPER.createArrayNode();
        message.set("To", toAddresses);
        var toAddress = OBJECT_MAPPER.createObjectNode();
        toAddresses.add(toAddress);
        toAddress.set("Email", OBJECT_MAPPER.valueToTree(toEmail));
        toAddress.set("Name", OBJECT_MAPPER.valueToTree(toName));
        message.set("Subject", OBJECT_MAPPER.valueToTree(subject));
        message.set("TextPart", OBJECT_MAPPER.valueToTree(text));
        //body.set("SandboxMode", OBJECT_MAPPER.valueToTree(true));
        return body;
    }

}
