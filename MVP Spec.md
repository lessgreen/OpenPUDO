LESS siavs

**High-level functional specification for PUDO App.**


[TOC]



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

Subsequent phases of the project, not needing to be included in the MVP, will include:

1. The possibility for the merchant to create a "showcase" of his offers, visible to users either on the App itself or on other social networks.
2. The chance of communication between destinees with the creation of "relationships", exchange of messages and, possibly, of "favors" (such as "go get this package for me").
3. The creation of a motivational reward system (karma green points), both for users and for merchants (this exercise is a "diamond green sustainer" because it has saved a total of cubic meters of CO2; this user is an "environment black belt "Because he saved a few km of vans, helped to involve N other users, collected packages for friends, etc.). These feedbacks can be visible as badges both online (in the App itself or on social networks) and offline (think about the “TripAdvisor sticker”).
4. The possibility for a PUDO to carry out the service also for structured distribution networks in change of a payment (with a functional logic, in this case, both contractually and economically brokered): work as a delivery point even for a "courier", being paid for each delivery, as it is for any other current PUDO network (see FermoPoint, Amazon corner, InDaBox, etc.). This function ("DEPOT") will have dedicated operational specifications, generally aligned with those of any existing PUDO network for the the PUDO+DEPOT App; this does not involve any change in the functions of  the "destinee" App, as in this case the recipients do not necessarily have any App installed.
5. The possibility for PUDO to offer premium services such as micro-delivery (home delivery on behalf of the sender and paid for as an advanced DEPOT), delivery by appointment or off-time (paid by the sender or recipient), etc.
6. The possibility for pudo to offer to its customers special deals (a-la "Too Good To Go"), leveraging the offline proximity relation between the PUDO and its users.

The following specification is more detailed on the basic functions, it being understood that the others, merely listed above, remain in the medium-term development roadmap.


## Project goals and constraints

As LESS we will offer the whole software suite (“OpenPUDO”) as Open Source Software copyrighted by LESS, the involved developers will need to agree to work as contractors for LESS, to grant LESS the copyright on the code and to agree to release it as OSS.

LESS will then offer the use of the service to the stakeholders (destinees and shops) as a free service (SaaS), it is therefore of paramount importance that the running costs at large numbers of users are taken in consideration when choosing development technologies, frameworks, external services and so on. As an example it could be perfectly acceptable to use technologies like Amazon Cognito to federate authentication of external users, but in the development plan should be considered the deployment cost of this choice that, for the predicted scale up to one million users, would impact about 4k€/month. This is acceptable, but MUST be known in advance.

The system must be planned to grow toward, as said, about one million users (destinees) and up to one hundred thousand PUDOs (shops), and deployment sizing should be done with these numbers in mind. It would be also perfectly acceptable to plan an initial MVO which relies on “high per user deployment cost” services in the initial phase, as long as these costs are known and predictable and a future switch off to different solutions is already planned and analysed to follow in a predictable way the user base growth.


# Recipient functions

_The recipient is simply the person who has chosen to use the system to collect his parcels from a PUDO._

_Scalability: 1 million. [Pay attention to the use of libraries, cloud services or things that has a variable cost]_


## Registration

Registration should be simple and "inviting" and include the following steps:



1. POSSIBLE Identification [OAuth integrated with Social Network, confirmation SMS, Document scan; ...]
2. Profile creation (name, telephone number, main address, other addresses, photos); possible access to the address book (to invite friends to use the App or to send them any offers)
3. Optional data entry (purchase preferences)
4. Acceptance of terms of use
5. Acceptance of privacy conditions

Note on SMS with activation OTP: it is possible to have the system autofill the OTP on both iOS and Android, this seems reasonably "friendly" (it is now accepted by users for anything), avoids many bots / spam, allows us to demonstrate our "reasonable effort" to identify the person and provide necessary elements for any interventions by the authorities; thus this approach seems reasonable for all cases in which an identity is not "imported" from third-party sources (social networks, OAuth).

Evaluate full Facebook / Instagram integration as an identity management tool, having identity management as a secondary fallback and with minor featureset with validated email / sms credentials.


## PUDO selection and agreement acceptance

Basically the recipient has to be able to choose a PUDO that is convenient for him/her based on his current location, primary address or selected address (eg: It would be convenient for me to take the packages close to my office); the PUDOs should be visible on a map and for each the essential information should be shown.

Steps:

1. Map view centered on geo-localized position with PUDOs shown
2. Display of PUDO access conditions and reviews
3. Acceptance of "contract" with PUDO which generates a request for an agreement with PUDO itself (if it is not an open PUDO with implicit acceptance, see below)
4. Possibility to designate several PUDO on a single account

In the launch phase it could be convenient to populate the map with the location of PUDOs available from existing network, telling the user "We are sorry, this PUDO cannot be used here by now, we will contact them and let you know soon". This would be useful to give the user a decent feedback on one side, and to gather information on points that is critical to acquire on the other.



## "Peer" selection [NOT IN THE MVP]

The recipient should be able to designate other registered recipients as people to whom "[s]he could" delegate the withdrawal, his "friends".

The "friendship" should be accepted, to be considered a V2 additional social features (see friends of friends, exchange messages, interaction / interconnection with FB possibly limited to a restricted group, "karma point" functionality visible on the network for those who use the service, bring friends in or collect for them, etc.).

However, the minimum functions are:



1. Selection / search of a "peer" (with exchange of QRCode or NFC information or more simply only existing contacts in the address book / social)
2. networkAcceptance of peer request
3. Possibility of sending an invitation by mail / messaging with a link to the download of the 'App and automatic "peer" connection

Check the hypothesis that a user can give a "permanent" proxy (example: husband, secretary, brother).

Note: In the scenario of full Facebook / instagram integration, validate the listing and send it to involve friends closest to your home and / or to the geographically selected PUDO points.


## Notification and collection or delegation

When the recipient receives notification of the package available to PUDO, he can go and collect it or delegate one of his "peers" to collect it for him:



1. The notification indicates that the package is available (photo of the label?)
2. The recipient can confirm that it will collect it, send a message to PUDO or ask for it to be withdrawn from a "peer".
3. The possible "peer" can accept the delegation, if the thing is notified to PUDO, or refuse it, if the refusal to the original recipient.
4. The recipient or the delegate can go to and pick PUDO with identification (document or photo profile) or trade confirmation NFC / QRCode

Hypothesis: if there are powers to "permanent" Withdrawal could be immediately notified of the arrival also to all delegates , as well as the successful withdrawal.


## Reviews

Recipients using a PUDO should be able to give PUDO a review.

We do not expect reviews of recipients by PUDO but the possibility of kick-out (recipient no longer affiliated) or ban (the recipient no longer sees this PUDO).

The user should be able to review a PUDO * only * after having delegated a withdrawal to it and having done it.

The review should have the classic characteristics of an attribution of scores in stars plus a short text, with:



1. Prefiltration of the text for F * words and semantic analysis (in backend)
2. Possibility for anyone who reads a review and for the PUDO reviewed to report improper reviews / insulting (and back office management for reports, priority if the report is)
3. from the merchantCalculation of average scores and number of reviews, to be displayed to users when viewing the PUDO in the area together with other statistics (age of the PUDO, total number of deliveries made, number ofusers, number of deliveries in the last month, ...)


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

In the scenario of full Facebook / Instagram integration, event notifications could also be sent and used off-app on Messanger / Whatsapp chat for greater integration of disintermediate follow-up with PUDO.


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

_is the establishment that offers the collection service and any additional delivery services independently and with a direct and disintermediated relationship with the recipient; in principle released from contractual relationships with the courier or with other networks._

_At the time of enrollment, PUDO also accepts "virtually" to carry out as a second activity that of DEPOT (ie a delivery point agreed on behalf of the "network" with any value-added services) against standard remuneration, but this only after the formalization of a contract with the network which makes it not only PUDO but also DEPOT, and the DEPOT functions are described separately._

_Scalability: 100 thousand. [Attention to any use of libraries, cloud service that has a variable cost]_


## Enrollment

The PUDO must basically do two enrollments, first an enrollment of physical persons (the owner of the tobacconist, the salesman who has his own mobile phone), this is the same function of the enrollment of the recipients, indeed each person can in turn be a "recipient" for other PUDOs.

Obviously the enrollment can and must have separate paths (as the first question the App asks if you are a PUDO or a recipient), but the underlying infrastructure is the same.

It is then necessary to do the enrollment of PUDO as an "exercise", which is a function that anyone can activate by proving to be the owner of the business, after having an account as a person.

Basically, the enrollment of PUDO is therefore in three phases: Identification (as for the recipients); definition of the merchant status (business name, address, location, picture of shop); Policy definition (see below).


## Policy definition

A PUDO can be, according to its choice: An Open Pudo (implicit acceptance of any recipient requesting it), a Closed Pudo (explicit acceptance, anyone can ask to become a recipient for that PUDO but PUDO chooses who to accept), or a Private Pudo (acceptance of destinees only upon invitation, PUDO does not even appear to uninvited recipients, for example a corporate PUDO or an internal facility).

The PUDO then outlines its policies, namely:



1. What does it want in exchange for the service (you have to buy something, you must be my regular customer, etc.)
2. Service hours (which do not necessarily coincide with the opening hours: a bar / diner may not provide the PUDO service from 12 to 15).
3. Size / weight limits of accepted packages

These policies will be shown to the recipient (and must be accepted) when selecting the PUDO on the map.

The functionality **What does it want in exchange for the service** is the heart of the LESS functional strategy and must be better defined from a marketing definition perspective, according to pre-defined choices by product category or type of PUDO. 

The functionality **What I want in exchange for the service **will in future esxtend towards the PUDO product-service catalog, which can be in the choice of "buy something", the possibility of expressing the preference of the product-service among those of the catalog wants to purchase from the catalog (always disintermediated). 

In this way, a sort of pre-order of the product-service of the store is carried out, promoting the products-services and favoring an “almost dynamic of local commerce” even if without integrating a full management of order fulfillment in the user-pudo relationship.


## "Reinforced PUD identification"

Enrolling PUDOs / exercises can optionally carry out an enrollment operation with "reinforced" identification, for two reasons:



1. To be able to operate also as a DEPOT
2. To have a "certified PUDO" badge, that is, PUDO for which LESS has taken charge to verify that it is a real and active business and that the registration is made in the name of the true legal representative; these elements are important to create trust (in addition to the review system) in users / recipients.

Step:



1. Entering the VAT number or CF of the year [The backend makes a chamberin API and extracts the legal representatives]
2. Entering the tax code of the physical person (owner/legal responsible) and verification
3. Signing with electronic signature of the agreement (electronic signature can also be scan of the identity document, tax code, recognition with video / selfie etc. Current KYC/AML identification providers offer the service around 1 €/person for a way deeper verification)

It will then be needed some backoffice procedure to validate and accept the PUDO.

Note: An identification with SPID with a click on the site would be nice.


## Functional delegations

The PUDO manager must be able to “delegate” the individual functions of the PUDO to other accounts (his clerks / employees), it being understood that each user has his own unique identity.

The manager must be able to see all the actions performed by his delegates, easily modify the proxies for the individual functions and / or remove them.

The system of delegation is hierarchical:



1. The owner of the PUDO is delegated to any function
2. Any delegate for a function can delegate the same function in turn
3. If a delegation is revoked, the redelegations by that delegate are revoked in cascade

The backend will keep track of the history of the proxies for documentary purposes (Ex: Tizio accepted / delivered because at that moment he was delegated through X-> Y-> Z to do so).


## Acceptance / denial of "customers"

For closed pudos, a recipient acceptance function must be provided which includes:



1. Notification of new recipient accreditation request
2. Display of the list of pending authorizations
3. Approval / denial
4. Display of list and search of existing authorizations
5. Display of accredited user details ( retreat history, other info)
6. Kick-out and ban function

For private PUDOs, a method of sending "invitations" to internal users is required, with at least two distinct approaches:



1. For small-scale solutions (private club): sending of invitation with message / mail / social / local communication between devices
2. For large-scale solutions (university, bank): API for interconnection with “corporate” systems. 


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
3. From list of packages in charge

If the identification did not start from data exchange with the recipient (NFC or QRcode) then the delivery must cause a notification to the recipient's App which must be able to confirm or deny.

If the recipient does not have his mobile phone with him, PUDO must be able to "force" the delivery by declaring that he has identified the recipient (from photo or by seeing a document).


## Promotional messages

A PUDO should be able to send promotional messages to recipients affiliated with him, the following must be provided:



*   Limits to the number of messages (one per month?)
*   Possible filtering for "zombie" users (your affiliated users receive it except those for four months have not withdrawn anything from you?)
*   Blocking of the single sender by the user (I no longer want to receive messages from this PUDO, with possible reporting of inappropriate messages)
*   Possible reporting to the back office of management of repeated blocks by users.

In principle the right to send messages to users should be clearly visible to these last ones when choosing a PUDO, together with the limits to such messages and the limits in delivery methods.

In example one shop might state “I will send at most one message per month, delivered as an home-page banner” and another might state “I will send up to one message per week, delivered as a push notification”; the user will then be able to accept this as part of the PUDO selection procedure or not. Should the PUDO change its rules these changes will take place after a while, giving the user the chance to choose another PUDO.


## Catalog

PUDO should be able to insert in some way a “catalog” of what it offers, also to make its proposal clearer in terms of policy (beyond the “you have to buy something”).

The upload procedure should be extremely simple (see ThePop) and a possible integration with FaceBook Local or other social channels should be evaluated. 


## "Proximity marketing" functions. XXX-Define


## Backoffice Interface 

There must be a backoffice interface that allows to:



*   Administer the different aspects of the pudo network (activation, deactivation, insertion, ban)
*   Provide advanced information analytics on the network status (users, volumes, activities, growth, environmental impact calculations, 
*   Manage onboarding pipelines
    *   Automation and print tracking and sending of information / promotional material to newly registered PUDOcenters
    *   Scheduling training calls from call
*   Ticketing platform for Operations


# Future Applications Development and Integration

Here are the functions that will need to be developed in second priority with respect to the PUDO application, but which will have to see its subsequent or anticipated development on the basis of opportunities for code / knowledge re-use.


## Postman functions - Crowdship

Functions related to the micro-delivery areas of the CrowdShip application [https: / /github.com/lessgreen/CrowdShip](https://github.com/lessgreen/CrowdShip) .

- This App must still be specified, it must include user registration, confirmation of availability and accreditation of a postman at a PUDO pick-up, the pick-up of shipments, delivery, delivery of shipments, notifications to automatic recipient users, reports of deliveries and non-deliveries, the possibility of collecting the signature on a touch smartphone.


## Functions Local Logistics Coordinator - Network Management

The functionality of the Local Logistics Coordinator is that of the user who coordinates a local network of Postmen with respect to shipments, being able to intervene to manage operational and availability problems. 

It is estimated that a network logistic coordinator could be reasonable to manage 120 Postini.

The application will have to manage, in conjunction with the Crowdship App, the management of notifications of availability within a configurable time to allow the local logistics coordinator to manage / activate any postmen "on the bench".

This application is that of Network Management [https://github.com/lessgreen/NetworkManagement](https://github.com/lessgreen/NetworkManagement) 


## Interconnection to Distribution Systems - CarrierConnectionBroker

Backend integrations with shipping distribution management information systems will be required, be it of a distribution supplier or an express courier (note: GLS Italy integration already available) which is the application. This is the form [https://github.com/lessgreen/CarrierConnectionBroker](https://github.com/lessgreen/CarrierConnectionBroker) 


## Planning management tool - Network Planner

To develop new PUDO networks and micro-delivery networks, it will be necessary to work with advanced data analysis with forecasting capabilities, to better identify in the current distribution topology based on vans, where to activate the PUDO and micro-networks. delivery. 

This is the one developed by Andrea in C ++ in the analysis models with genetic algorithms and high geocoding.

[https://github.com/lessgreen/NetworkPlanner](https://github.com/lessgreen/NetworkPlanner) 


## Data analysis on existing PUDO networks: PUDO Research

Analysis and research on data related to pudo networks, including scraping of existing network points and publication of scraping software, lists and analysis. 

This will be done, with great impact, by publishing data acquired through scraping, being able to represent the networks.

[https://github.com/lessgreen/PUDOResearch](https://github.com/lessgreen/PUDOResearch)


## Interconnection between different PUDO networks - PUDO Connection Broker

While each PUDO network can activate itself and federate itself using the OpenPUDO software, it will be natural and necessary to interconnect to other existing pudo networks, and for this it will be available a PUDO Connection Broker that enables interconnection with standard APIs and libraries.

The network of Tigotà stores may want to have control of the information and data systems, which already has store logistics functions for pickup, dropoff and order fullfilment, and will therefore be able to interconnect them with the PUDO Connection Broker to a network based on OpenPUDO. . 

This is the PUDO Connection Broker [https://github.com/lessgreen/PUDOConnectionBroker](https://github.com/lessgreen/PUDOConnectionBroker)

