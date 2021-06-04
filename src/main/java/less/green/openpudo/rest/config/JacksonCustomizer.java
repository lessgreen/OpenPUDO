package less.green.openpudo.rest.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import io.quarkus.jackson.ObjectMapperCustomizer;
import javax.inject.Singleton;

@Singleton
public class JacksonCustomizer implements ObjectMapperCustomizer {

    @Override
    public void customize(ObjectMapper objectMapper) {
        // disable serialization of null fields
        // objectMapper.setSerializationInclusion(JsonInclude.Include.NON_ABSENT);
    }

}
