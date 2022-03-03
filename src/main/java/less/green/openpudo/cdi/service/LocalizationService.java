package less.green.openpudo.cdi.service;

import lombok.extern.log4j.Log4j2;

import javax.enterprise.context.ApplicationScoped;
import java.text.MessageFormat;
import java.util.Locale;
import java.util.MissingResourceException;
import java.util.ResourceBundle;

import static less.green.openpudo.common.StringUtils.isEmpty;

@ApplicationScoped
@Log4j2
public class LocalizationService {

    public static final Locale DEFAULT_LOCALE = Locale.ENGLISH;

    public String getMessage(String language, String key, Object... params) {
        ResourceBundle bundle;
        if (isEmpty(language)) {
            bundle = ResourceBundle.getBundle("localization/messages", DEFAULT_LOCALE);
        } else {
            Locale locale = new Locale(language);
            bundle = ResourceBundle.getBundle("localization/messages", locale);
            if (!bundle.getLocale().getLanguage().equals(locale.getLanguage())) {
                log.warn("Message bundle not found for language: {}", language);
                bundle = ResourceBundle.getBundle("localization/messages", DEFAULT_LOCALE);
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
        MessageFormat formatter = new MessageFormat(pattern, DEFAULT_LOCALE);
        return formatter.format(params);
    }

}
