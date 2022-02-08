# openpudo-rest
OpenPUDO REST server

### Common API return codes
Each API has a return code that gives information about the outcome of the execution.
Code 0 always indicates a successful operation, otherwise the return code reuses the semantic of HTTP status codes, with an additional detail message.
- 0: `OK` -> success
- 400: `BAD_REQUEST` -> operation failed for reasons related to the caller (e.g. mandatory parameters missing, invalid formats, operation incompatible with business logic)
- 401: `INVALID_JWT_TOKEN` -> operation called with an invalid JWT token
- 401: `EXPIRED_JWT_TOKEN` -> operation called with an expired JWT token
- 401: `INVALID_OTP` -> login attempt with an invalid OTP code
- 403: `FORBIDDEN` -> operation failed for missing privileges (e.g. fetching information about a package owner by another user)
- 404: `RESOURCE_NOT_FOUND` -> operation failed for update on non-existing entity
- 500: `INTERNAL_SERVER_ERROR` -> operation failed for reasons related to our backend server (e.g. uncaught exception, database problems, bugs)
- 503: `SERVICE_UNAVAILABLE` -> operation failed for reasons related to third party server (e.g. geolocation engine, storage server)

### Package Finite State Automaton
Those are the states that define the package lifecycle, and the rules that govern the state transition.

- `DELIVERED` state: package has been delivered to the PUDO by the courier  
    - after 5 minutes a notification is sent to the customer and the package goes into `NOTIFY_SENT` state

- `NOTIFY_SENT` state: a notification has been sent to the customer, signaling a package ready to be collected
    - the state goes into `NOTIFIED` by calling the API `/packages/{packageId}/notified`
    - the state goes into `COLLECTED` by calling the API `/packages/{packageId}/collected`
    - the state goes into `ACCEPTED` by calling the API `/packages/{packageId}/accepted`
    - after 24 hours another notification is sent to the customer, but the state remains `NOTIFY_SENT`
    - after 30 days from the first package event, the state automatically goes into `EXPIRED`

- `NOTIFIED` state: the user has read the notification and confirms to be aware of the package ready to be collected
    - the state goes into `COLLECTED` by calling the API `/packages/{packageId}/collected`
    - the state goes into `ACCEPTED` by calling the API `/packages/{packageId}/accepted`
    - after 30 days from the first package event, the state automatically goes into `EXPIRED`

- `COLLECTED` state: the customer has collected the package from the PUDO
    - the state goes into `ACCEPTED` by calling the API `/packages/{packageId}/accepted`
    - after 7 days, the state automatically goes into `ACCEPTED`

- `ACCEPTED` state: the customer has confirmed the package collection
    - this is a final stage and can't be further modified

- `EXPIRED` state: the package has been left in PUDO's warehouse for too long without being collected
    - this is a final stage and can't be further modified, except for manual intervention by customer service
