-- Very, VERY preliminary (autogenerated) template for the backend data structures


CREATE TABLE Address
(
  recordID INT NOT NULL,
  intro VARCHAR(80) NOT NULL,
  street VARCHAR(80) NOT NULL,
  streetNO VARCHAR(10) NOT NULL,
  notes VARCHAR(80) NOT NULL,
  ZIP VARCHAR(6) NOT NULL,
  city VARCHAR(40) NOT NULL,
  province VARCHAR(3) NOT NULL,
  country CHAR(2) NOT NULL,
  lon FLOAT NOT NULL,
  lat FLOAT NOT NULL,
  PRIMARY KEY (recordID)
);

CREATE TABLE externalFile
(
  uuid CHAR(32) NOT NULL,
  storage CHAR(20) NOT NULL,
  path VARCHAR(64) NOT NULL,
  mimeType VARCHAR(64) NOT NULL,
  PRIMARY KEY (uuid)
);

CREATE TABLE Network
(
  ID CHAR(4) NOT NULL,
  description VARCHAR(80) NOT NULL,
  PRIMARY KEY (ID)
);

CREATE TABLE Person
(
  recordID INT NOT NULL,
  id@domain VARCHAR(30) NOT NULL,
  accessKey VARCHAR(44) NOT NULL,
  firstName VARCHAR(40) NOT NULL,
  lastName VARCHAR(40) NOT NULL,
  email VARCHAR(60) NOT NULL,
  phone VARCHAR(14) NOT NULL,
  SSN VARCHAR(16) NOT NULL,
  fkImage CHAR(32) NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (fkImage) REFERENCES externalFile(uuid)
);

CREATE TABLE Pudo
(
  recordID INT NOT NULL,
  businessName INT NOT NULL,
  status INT NOT NULL,
  VAT VARCHAR(15) NOT NULL,
  contactPhone VARCHAR(13) NOT NULL,
  contactNotes VARCHAR(256) NOT NULL,
  fkNetwork CHAR(4) NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (fkNetwork) REFERENCES Network(ID)
);

CREATE TABLE personAddress
(
  seq INT NOT NULL,
  fkPerson INT NOT NULL,
  fkAddress INT NOT NULL,
  PRIMARY KEY (fkPerson, fkAddress),
  FOREIGN KEY (fkPerson) REFERENCES Person(recordID),
  FOREIGN KEY (fkAddress) REFERENCES Address(recordID)
);

CREATE TABLE pudoAddress
(
  seq INT NOT NULL,
  fkAddress INT NOT NULL,
  fkPudo INT NOT NULL,
  PRIMARY KEY (fkAddress, fkPudo),
  FOREIGN KEY (fkAddress) REFERENCES Address(recordID),
  FOREIGN KEY (fkPudo) REFERENCES Pudo(recordID)
);

CREATE TABLE Package
(
  recordID INT NOT NULL,
  status INT NOT NULL,
  deliveredAt INT NOT NULL,
  ownedBy INT NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (deliveredAt) REFERENCES Pudo(recordID),
  FOREIGN KEY (ownedBy) REFERENCES Person(recordID)
);

CREATE TABLE Events
(
  recordID INT NOT NULL,
  timeStamp timestamp NOT NULL,
  notes VARCHAR(512) NOT NULL,
  fkPackage INT NOT NULL,
  fkAddress INT NOT NULL,
  fkImage CHAR(32) NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (fkPackage) REFERENCES Package(recordID),
  FOREIGN KEY (fkAddress) REFERENCES Address(recordID),
  FOREIGN KEY (fkImage) REFERENCES externalFile(uuid)
);

CREATE TABLE Friendship
(
  Type INT NOT NULL,
  timestamp INT NOT NULL,
  delegations INT NOT NULL,
  version INT NOT NULL,
  fkPersonLeft INT NOT NULL,
  fkPersonRight INT NOT NULL,
  fkUpdater INT NOT NULL,
  PRIMARY KEY (version, fkPersonLeft, fkPersonRight),
  FOREIGN KEY (fkPersonLeft) REFERENCES Person(recordID),
  FOREIGN KEY (fkPersonRight) REFERENCES Person(recordID),
  FOREIGN KEY (fkUpdater) REFERENCES Person(recordID)
);

CREATE TABLE Validation
(
  recordID INT NOT NULL,
  notes VARCHAR(512) NOT NULL,
  kfPudo INT NOT NULL,
  fkOwner INT NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (kfPudo) REFERENCES Pudo(recordID),
  FOREIGN KEY (fkOwner) REFERENCES Person(recordID)
);

CREATE TABLE Document
(
  seq INT NOT NULL,
  processed timestamp NOT NULL,
  fkValidation INT NOT NULL,
  uuid CHAR(32) NOT NULL,
  PRIMARY KEY (seq, fkValidation),
  FOREIGN KEY (fkValidation) REFERENCES Validation(recordID),
  FOREIGN KEY (uuid) REFERENCES externalFile(uuid)
);

CREATE TABLE Review
(
  recordID INT NOT NULL,
  date DATE NOT NULL,
  stars INT NOT NULL,
  text VARCHAR(512) NOT NULL,
  medals INT NOT NULL,
  fkPudo INT NOT NULL,
  fkPerson INT NOT NULL,
  fkPicture CHAR(32) NOT NULL,
  PRIMARY KEY (recordID),
  FOREIGN KEY (fkPudo) REFERENCES Pudo(recordID),
  FOREIGN KEY (fkPerson) REFERENCES Person(recordID),
  FOREIGN KEY (fkPicture) REFERENCES externalFile(uuid)
);

CREATE TABLE Role
(
  roleType INT NOT NULL,
  roleFlags INT NOT NULL,
  version INT NOT NULL,
  timeStamp timestamp NOT NULL,
  fkPerson INT NOT NULL,
  fkPudo INT NOT NULL,
  grantedBy INT NOT NULL,
  grantedOn INT NOT NULL,
  grantedAs INT NOT NULL,
  PRIMARY KEY (version, fkPerson, fkPudo),
  FOREIGN KEY (fkPerson) REFERENCES Person(recordID),
  FOREIGN KEY (fkPudo) REFERENCES Pudo(recordID),
  FOREIGN KEY (grantedBy, grantedOn, grantedAs) REFERENCES Role(fkPerson, fkPudo, version)
);
