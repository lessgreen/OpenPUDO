# OpenPUDO
Open PUDO Software Platform

### Setup instructions
- Create a [PostgreSQL](https://www.postgresql.org/) schema and initialize it with the script [schema_ddl.sql](openpudo-rest/assets/sql/schema_ddl.sql).
- Create a folder for storing application's binary data (e.g. users profile picture), this can be a mounted NSF share.
- Register your application on [Firebase](https://firebase.google.com/) to enable sending push notifications from the back-end, and save your `firebase-config.json` file.
- Register at [Geocode Earth](https://geocode.earth/), that will be the provider for geocoding queries.
- Register at [mailjet](https://www.mailjet.com/), that will be the provider for outgoing email and SMS messages.
- Build the back-end UberJAR as a standard [Maven](https://maven.apache.org/) Java project with `mvn clean install`.
- Create a `.env` file that must be placed in the same folder of the UberJAR, this file is used to create an environment for the back-end with configuration parameters and credentials.  
A configuration example is provided in the file [.env.example](openpudo-rest/assets/config/.env.example).
- Put a reverse proxy for SSL termination and load balancing between the nodes.
- Build the mobile app and publish it on Apple and Google store.

### Swagger
When the back-end is up and running, a full functioning Swagger will be available to document and test application APIs.  
A live instance can be found at [https://api.quigreen.it/q/swagger-ui/](https://api.quigreen.it/q/swagger-ui/)

### PUDO definition
This project aims to provide a standard PUDO definition than can be used for integration between shipping providers. The current PUDO structure is the following:

```json
{
  "pudoId": 0,
  "createTms": "2021-11-10",
  "updateTms": "2021-11-10",
  "businessName": "string",
  "vat": "string",
  "contactNotes": "string",
  "phoneNumber": "string",
  "profilePicId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "address": {
    "addressId": 0,
    "createTms": "2021-11-10",
    "updateTms": "2021-11-10",
    "label": "string",
    "street": "string",
    "zipCode": "string",
    "streetNum": "string",
    "city": "string",
    "province": "string",
    "country": "string",
    "lat": 0,
    "lon": 0
  }
}
```