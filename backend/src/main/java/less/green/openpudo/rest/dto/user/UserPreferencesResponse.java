package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.TypedResponse;
import org.eclipse.microprofile.openapi.annotations.media.Schema;

import java.util.UUID;

@Schema
public class UserPreferencesResponse extends TypedResponse<UserPreferences> {

    public UserPreferencesResponse(UUID executionId, int returnCode, UserPreferences payload) {
        super(executionId, returnCode, payload);
    }

}
