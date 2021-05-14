package less.green.openpudo.cdi.service;

import java.text.MessageFormat;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import javax.enterprise.context.ApplicationScoped;
import lombok.extern.log4j.Log4j2;

@ApplicationScoped
@Log4j2
public class LocalizationService {

    public String getMessage(String key, Object... params) {
        ResourceBundle bundle = ResourceBundle.getBundle("localization/messages");
        String pattern;
        try {
            pattern = bundle.getString(key);
        } catch (MissingResourceException ex) {
            return ex.getMessage();
        }
        if (params == null || params.length == 0) {
            return pattern;
        }
        MessageFormat formatter = new MessageFormat(pattern, Locale.ENGLISH);
        String msg = formatter.format(params);
        return msg;
    }

}
