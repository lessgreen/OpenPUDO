# openpudo-rest
OpenPUDO REST server

### Codici di ritorno comuni a tutte le API
Ogni chiamata API restituisce un codice che fornisce informazioni sullo stato della stessa.
A parte il codice 0 che indica sempre una operazione avvenuta con successo, quando possibile vengono riutilizzati gli HTTP status codes,
per una più immediata comprensione, qualora non fosse necessario un maggior livello di dettaglio.  
- 0: `OK` -> la chiamata ha avuto successo
- 400: `BAD_REQUEST` -> chiamata sintatticamente valida, fallita per cause semantiche imputabili al chiamante (ad esempio: errori di formato o modifiche di stato incompatibili con le logiche applicative)
- 401: `INVALID_JWT_TOKEN` -> API invocata con token JWT non valido
- 401: `EXPIRED_JWT_TOKEN` -> API invocata con token JWT scaduto
- 401: `INVALID_OTP` -> tentativo di login effettuato con codice OTP non valido
- 403: `FORBIDDEN` -> chiamata fallita per privilegi mancanti (ad esempio: update su entità di proprietà di un altro utente)
- 404: `RESOURCE_NOT_FOUND` -> chiamata fallita per operazione dispositiva su entità inesistente
- 500: `INTERNAL_SERVER_ERROR` -> chiamata fallita per cause imputabili al back-end (ad esempio: bug, problemi di comunicazione col database)
- 503: `SERVICE_UNAVAILABLE` -> chiamata fallita per cause imputabili a sistemi terzi (ad esempio: geolocalizzazione, storage)

### FSA Pacchi
Di seguito vengono elencati i possibili stati in cui un pacco si può trovare, e le logiche di passaggio tra gli stessi.

- stato `DELIVERED`: il pacco è stato ricevuto dal PUDO  
    - dopo 2 minuti viene inviata notifica all'utente ed lo stato passa automaticamente in `NOTIFY_SENT`

- stato `NOTIFY_SENT`: è stata inviata una notifica all'utente, indicando la presenza di un pacco da ritirare
    - lo stato passa in `NOTIFIED` mediante la chiamata all'API `/packages/{packageId}/notified`
    - lo stato passa in `COLLECTED` mediante la chiamata all'API `/packages/{packageId}/collected`
    - lo stato passa in `ACCEPTED` mediante la chiamata all'API `/packages/{packageId}/accepted`
    - dopo 24 ore viene inviata una nuova notifica e lo stato rimane in `NOTIFY_SENT`
    - dopo 7 giorni viene inviata una nuova notifica e lo stato passa automaticamente in `EXPIRED`

- stato `NOTIFIED`: l'utente ha confermate di essere informato della presenza di un pacco da ritirare
    - lo stato passa in `COLLECTED` mediante la chiamata all'API `/packages/{packageId}/collected`
    - lo stato passa in `ACCEPTED` mediante la chiamata all'API `/packages/{packageId}/accepted`
    - dopo 7 giorni viene inviata una nuova notifica e lo stato passa automaticamente in `EXPIRED`

- stato `COLLECTED`: il PUDO ha consegnato il pacco all'utente
    - lo stato passa in `ACCEPTED` mediante la chiamata all'API `/packages/{packageId}/accepted`
    - dopo 7 giorni lo stato passa automaticamente in `ACCEPTED`

- stato `ACCEPTED`: l'utente ha confermato di aver ritirato il pacco
    - questo è uno stato finale e non prevede ulteriori cambiamenti

- stato `EXPIRED`: il pacco è rimasto troppo a lungo in giacenza nel PUDO senza che l'utente lo ritirasse
    - questo è uno stato finale e non prevede ulteriori cambiamenti, a meno di interventi da parte del backoffice
