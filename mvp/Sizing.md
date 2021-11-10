<!-- Output copied to clipboard! -->



## Backend Scalability Analysis

In this document we expose some numbers useful for the sizing of the backend platform.


### Planned service figures

The platform should scale, nation wide, to:



*   2’000’000 recipients registered and active
*   200’000 registered and active PUDOs

It can be considered a federated solution, especially for multi-nation scale-up. Meaning that the users from each nation could be considered a separate environment, by simply duplicating the setup. Eventually federation solutions with data exchange between the installations will be developed.

Estimates for other sizing figures in terms of transactions, guessed on the basis of the above with safeguard abundance, follow:



*   100’000’000 million deliveries handled per year (about one per week per user), that is 3 TPS on average for each core state transition, but considering the contemporaneity factor we should expect these to be concentrated in a two-hours slot for the 250 working days, with further peaks ranges (i.e. tuesday, before christmas, black friday, etc). It makes sense to size the platform to handle at least 200-400 TPS on peak.
*   10’000’000 realtime messages/notifications per day (about five per user, it is not a chat platform), that is 1-2 kmsgs/sec.


### Static sizing (storage)

The storage does not seem to be a big issue for all the core functions except the images of the packages.

Even considering 10 kilobytes per user or PUDO and 1 kb of data per delivery the storage size would be in the range 2-4 TB; which is perfectly feasible to handle even on a single node DB.

The only critical storage is about the pictures of the delivered boxes, should these be stored at high resolution the figures would easily go in the range of hundreds to terabytes.

Taking in count that the App should scale down and compress the images to a reasonable size client-side we should still expect about 200KiB per image, which means 20 TB per year.

A separate storage, outside the database and likely in a simulated filesystem in Cloud or a dedicated storage platform should be considered.


### Dynamic sizing (transactions and bandwidth)

The estimated speed of 200 TPS in the backend should be guaranteed for each of the core functionalities in the process, i.e.:



*   The PUDO receives a package and uploads the picture: the picture must be stored, the shipping object created, the image analysed for extracting the data, the recipient identified and notified
*   The user withdraws the package: Again an image analysis could be required, the states changed.

The real-time messaging is likely going to be a normal XMPP platform embedded in the core, A few kMSG/s is not an issue for any setup.

For the bandwidth usage the figures are, once again, driven by the pictures to be uploaded from the PUDO and dispatched to the recipient. Considering the requestea peak capability of 200 TPS and an average image size fo 200 KiB this means 40 MiB/s or half gigabit/sec for the images. A common GBit/sec connection should suffice.
