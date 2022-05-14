# LESS siavs

**High-level functional specification for PUDO App.
Reduced MPV version**


# Introduction

This document constitutes the high-level functional specification of the App of the PUDO project.

It is not a technical development specification (which will be more detailed and will contain a series of specific requirements to be contracted with the developers) nor an implementation map with functional division of the software components (which will lead to the decision of what goes into the front end and what in the back end, if you use a single App or multiple Apps, if the Apps can be based on cloud services or not, and so on).

Here we only define, for each "actor" who uses the system, which are the macro-functions available to that actor.

Each chapter describes an actor (category of people or entities that interact with the system) and each paragraph describes a macro-function this actor has access to.

For convenience and clarity, the actors have been indicated with names that differ from similar concepts in the jargon of couriers that would be misleading (for example, while the "driver" is the one who drives the van, the "delivery man" is the one who delivers the parcels on behalf of PUDO); for clarity in each chapter there is a brief description of the actor.


## Application field

In the initial phase, the project aims to develop an App which constitutes a communication platform between "disintermediated PUDOs" (Disintermediated Pick Up and Drop Off points) and recipients; PUDOs are points where buyers of eCommerce goods (the "recipients") can collect their purchases by indicating the PUDO as shipping address to the seller.

A PUDO is an existing shop that carries out this activity (in our model) to promote its business and attract customers, it could also be some subject having a physical presence on the territory and affiliated users (eg: Associations, Schools, Private Companies, Gyms, etc); potential customers are recipients of goods purchased online who, instead of waiting at home for a courier without knowing when they will step by, prefer to have the delivery address at the shop and then go to take the goods when it is comfortable; both will have the environmental cause as a further motivation (concentrating the deliveries in a few locations reduces the environmental impact of eCommerce).

The platform will be offered as a free service (both for the PUDO and for the recipients) and will be aimed exclusively at facilitating the meeting between these two stakeholders.


## Project goals and constraints

As LESS we will offer the whole software suite (“OpenPUDO”) as Open Source Software copyrighted by LESS, the involved developers will need to agree to work as contractors for LESS, to grant LESS the copyright on the code and to agree to release it as OSS.

LESS will then offer the use of the service to the stakeholders (destinees and shops) as a free service (SaaS), it is therefore of paramount importance that the running costs at large numbers of users are taken in consideration when choosing development technologies, frameworks, external services and so on. As an example it could be perfectly acceptable to use technologies like Amazon Cognito to federate authentication of external users, but in the development plan should be considered the deployment cost of this choice that, for the predicted scale up to one million users, would impact about 4k€/month. This is acceptable, but MUST be known in advance.

The system must be planned to grow toward, as said, about one million users (destinees) and up to one hundred thousand PUDOs (shops), and deployment sizing should be done with these numbers in mind. It would be also perfectly acceptable to plan an initial MVO which relies on “high per user deployment cost” services in the initial phase, as long as these costs are known and predictable and a future switch off to different solutions is already planned and analysed to follow in a predictable way the user base growth.


# Recipient functions

_The recipient is simply the person who has chosen to use the system to collect his parcels from a PUDO._

_Scalability: 1 million. [Pay attention to the use of libraries, cloud services or things that has a variable cost]_


## Registration

Registration should be simple and "inviting" and include the following steps:



1. Identification, initially only through Cognito or similar library or providing an email, phone and password (no identification check)
2. Profile creation (name, telephone number, main address, other addresses, photos)
3. Optional data entry (purchase preferences)
4. Acceptance of terms of use
5. Acceptance of privacy conditions


## PUDO selection and agreement acceptance

Basically the recipient has to be able to choose a PUDO that is convenient for him/her based on his current location, primary address or selected address (eg: It would be convenient for me to take the packages close to my office); the PUDOs should be visible on a map and for each the essential information should be shown.

Steps:

1. Map view centered on geo-localized position with PUDOs shown
2. Display of PUDO access conditions and reviews
3. Acceptance of "contract" with PUDO which generates a request for an agreement with PUDO itself (if it is not an open PUDO with implicit acceptance, see below)
4. Possibility to designate several PUDO on a single account

In the launch phase it could be convenient to populate the map with the location of PUDOs available from existing network, telling the user "We are sorry, this PUDO cannot be used here by now, we will contact them and let you know soon". This would be useful to give the user a decent feedback on one side, and to gather information on points that is critical to acquire on the other.


## Notification and collection

When the recipient receives notification of the package available to PUDO, he can go and collect it:

1. The notification indicates that the package is available (photo of the label?)
2. The recipient can confirm that it will collect it or send a message to PUDO.


## Affiliated PUDO suggestion 

The user / recipient must be able to "refer" a PUDO, proposing it as interesting, so that those who do network development can contact the shop and propose the App.

The report must contain the name of the business but can optionally contain:

*   Photo of the business
*   Geolocation
*   Authorization to contact the shop "in the name of"
*   Other free information

The report and, increasingly, any subsequent agreement of the PUDO reported by a user should allow the user to earn green karma points.


## Advanced Notifications

The recipient app should include an advanced push notification system that allows both the reporting of operational events ("Your package has arrived") and any information / promotional messages ("We have added this feature", "The fantastic bar below your house is now a PUDO too ”,…).


## Ideas on the user experience

The App (after registration) should open with a panel with multiple views selectable by icons, such as:

*   My dashboard (the CO2 I have saved, the statistics, the scores, any notifications)
*   My friends (with option to invite others in the address book, delegation management, etc.)
*   My PUDO (with the options to deactivate them, add them, suggest one).
*   My packages (shipments currently awaiting collection).
*   The history of the shipments received.
*   Settings.

Creative contributions are to be evaluated such as: if I send you a notification that a package has arrived, I am attaching the weather or traffic forecasts of the route / area from where you are to PUDO.

If the App is opened by a notification it should already present itself with the appropriate screen to manage it.

The integration with social networks should be analyzed, for example to publish the environmentalist karma "badges" on social networks, or to publish the photo of the withdrawal, of the package, etc. ("Hey, I'm here at the cippalippa bar I collect the new aifòn ... ").

To be evaluated: access to the location, hyper-local offers in push, internal navigation map with highlighted friends and cazzimazzi (a Beyond Waze?).


# PUDO functions

_A PUDO is the shop/location that offers the collection service and any additional delivery services independently and with a direct and disintermediated relationship with the recipient; in principle released from contractual relationships with the courier or with other networks._

_At the time of enrollment, PUDO also accepts "virtually" to carry out as a second activity that of DEPOT (ie a delivery point agreed on behalf of the "network" with any value-added services) against standard remuneration, but this only after the formalization of a contract with the network which makes it not only PUDO but also DEPOT, and the DEPOT functions are described separately._

_Scalability: 100 thousand. [Pay attention to the use of libraries, cloud services or things that has a variable cost]_

## Enrollment

The PUDO must basically do two enrollments, first an enrollment of physical persons (the owner of the tobacconist, the salesman who has his own mobile phone), this is the same function of the enrollment of the recipients, indeed each person can in turn be a "recipient" for other PUDOs.

Obviously the enrollment can and must have separate paths (as the first question the App asks if you are a PUDO or a recipient), but the underlying infrastructure is the same.

It is then necessary to do the enrollment of PUDO as a "business", which is a function that anyone can activate by proving to be the owner of the business, after having an account as a person; in the MVP there is no need for any check about the true ownership of tyhe business: it will be manually verified in the bakoffice.

Basically, the enrollment of PUDO is therefore in three phases: Identification (as for the recipients); definition of the merchant status (business name, address, location, picture of shop); Policy definition (see below).


## Policy definition

A PUDO can be, according to its choice: An Open Pudo (implicit acceptance of any recipient requesting it), a Closed Pudo (explicit acceptance, anyone can ask to become a recipient for that PUDO but PUDO chooses who to accept), or a Private Pudo (acceptance of destinees only upon invitation, PUDO does not even appear to uninvited recipients, for example a corporate PUDO or an internal facility).

The PUDO then outlines its policies, namely:

1. What does it want in exchange for the service (you have to buy something, you must be my regular customer, etc.)
2. Service hours (which do not necessarily coincide with the opening hours: a bar / diner may not provide the PUDO service from 12 to 15).
3. Size / weight limits of accepted packages
4. Requests for permissions like sending Adv messages to the App home page of the recipient or as push notification with an explicit frequency limit (up to X per week/month) and category (special offers, extra openings/closing, free leftovers giveouts, etc...)

These policies will be shown to the recipient (and must be accepted) when selecting the PUDO on the map.

The functionality **What does it want in exchange for the service** is the heart of the LESS functional strategy and must be better defined from a marketing definition perspective, according to pre-defined choices by product category or type of PUDO. 

The functionality **What I want in exchange for the service** will in future extend towards the PUDO product-service catalog, which can be in the choice of "buy something", the possibility of expressing the preference of the product-service among those of the catalog wants to purchase from the catalog (always disintermediated). 

In this way, a sort of pre-order of the product-service of the store is carried out, promoting the products-services and favoring an “almost dynamic of local commerce” even if without integrating a full management of order fulfillment in the user-pudo relationship.

**In the MVP the "policy" can be simply a text box where the PUDO writes its rules or a small form with some structured data (service times, size/weight limits) and a free text to describe what they want in exchange for the service.**


## Goods acceptance

The acceptance must be idiot-proof. In the main screen of the App we should have a function which consists directly in acquiring the label from the camera.

The acquired image must be sent to the backend where the AI ​​identifies the type of label, reads the relevant fields, reconciles the information with the list of accredited recipients and records the arrival of the package by notifying the recipient.

If the system does not automatically detect the recipient from the photo with adequate confidence, the user will be asked to select which of the accredited users it belongs to.

It may be necessary, especially in the tuning phase, a back office that takes care of problems.


## Delivery

Delivery is also a critical step in terms of efficiency and speed.

PUDO must be able to select the package to be delivered in various ways:

1. From recipient recognition (QRcode, NFC)
2. From photo label with processing similar to acceptance
3. From list of packages in charge [In the MVP this might be ok as the only option]

If the identification did not start from data exchange with the recipient (NFC or QRcode) then the delivery must cause a notification to the recipient's App which must be able to confirm or deny.

If the recipient does not have his mobile phone with him, PUDO must be able to "force" the delivery by declaring that he has identified the recipient (from photo or by seeing a document). [In the MVP this might be ok as the only option]

# Backoffice Interface 

There must be a backoffice interface that allows to:

*   Administer the different aspects of the pudo network (activation, deactivation, insertion, ban)
*   Provide advanced information analytics on the network status (users, volumes, activities, growth, environmental impact calculations, 
*   Manage onboarding pipelines
    *   Automation and print tracking and sending of information / promotional material to newly registered PUDOcenters
    *   Scheduling training calls from call
*   Ticketing platform for Operations

**In the MVP it is reasonable that these functions have an interface not delivered as a mobile App that gives only functions essential to the management of the network**



