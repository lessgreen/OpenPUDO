package less.green.openpudo.cdi.service;

import java.text.MessageFormat;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import javax.enterprise.context.ApplicationScoped;
import static less.green.openpudo.common.StringUtils.isEmpty;
import lombok.extern.log4j.Log4j2;

@ApplicationScoped
@Log4j2
public class LocalizationService {

    private static final String DEFAULT_LANGUAGE = "en";

    public String getMessage(String key, Object... params) {
        return getLocalizedMessage(DEFAULT_LANGUAGE, key, params);
    }

    public String getLocalizedMessage(String language, String key, Object... params) {
        ResourceBundle bundle;
        if (isEmpty(language)) {
            bundle = ResourceBundle.getBundle("localization/messages", Locale.ENGLISH);
        } else {
            Locale locale = new Locale(language);
            bundle = ResourceBundle.getBundle("localization/messages", locale);
            if (!bundle.getLocale().getLanguage().equals(locale.getLanguage())) {
                log.warn("Message bundle not found for language: {}", language);
                bundle = ResourceBundle.getBundle("localization/messages", Locale.ENGLISH);
            }
        }
        String pattern;
        try {
            pattern = bundle.getString(key);
        } catch (MissingResourceException ex) {
            log.error("Key not found in message bundle: {}", key);
            return key;
        }
        if (params == null || params.length == 0) {
            return pattern;
        }
        MessageFormat formatter = new MessageFormat(pattern, Locale.ENGLISH);
        String msg = formatter.format(params);
        return msg;
    }

}
