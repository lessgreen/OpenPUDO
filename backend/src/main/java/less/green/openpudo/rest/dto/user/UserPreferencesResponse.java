package less.green.openpudo.rest.dto.user;

import less.green.openpudo.rest.dto.TypedResponse;

import java.util.UUID;

public class UserPreferencesResponse extends TypedResponse<UserPreferences> {

    public UserPreferencesResponse(UUID executionId, int returnCode, UserPreferences payload) {
        super(executionId, returnCode, payload);
    }

}
