-------------------------------------------------------------------
-------------------------------------------------------------------
-- Homework 1 Problem 1
-- Starting with the single-table Global Terrorism Database, 
-- create a normalized relational schema. The schema should be in 
-- BCNF or in 3rd Normal Form.

-- Incident Locaton (III, pg 15 of the Codebook)
CREATE TABLE Region
(
    region     INT     PRIMARY KEY,
    region_txt TEXT    NOT NULL UNIQUE
);

CREATE TABLE Country
(
    country     SMALLINT  PRIMARY KEY,
    country_txt TEXT    NOT NULL UNIQUE,
    region      INT     NOT NULL REFERENCES Region(region)
);

CREATE TABLE Coordinates
(  
    latitude  REAL,
    longitude REAL,
    PRIMARY KEY (latitude, longitude), 
    city      TEXT,
    provstate TEXT,
    country   SMALLINT NOT NULL REFERENCES Country(country)
);

CREATE TABLE AlternativeDesignation
(
    alternative     SMALLINT     PRIMARY KEY,
    alternative_txt VARCHAR(255) NOT NULL UNIQUE
);

------------------------------------------------------------------------------------------

-- (All 1-9)
CREATE TABLE GTD
(
    -- GTD ID and Date (I, pg 11 in the codebook)
    eventid     BIGINT     PRIMARY KEY,
    iyear       SMALLINT   NOT NULL,
    imonth      SMALLINT   NOT NULL,
    iday        SMALLINT   NOT NULL,
    approxdate  TEXT,
    extended    BOOLEAN,
    resolution  TEXT,

    -- Incident information (II, pg 12 in the Codebook)
    summary     TEXT,
    crit1       BOOLEAN    NOT NULL,
    crit2       BOOLEAN    NOT NULL,
    crit3       BOOLEAN    NOT NULL,
    doubtterr   SMALLINT   NOT NULL,
    multiple    BOOLEAN    NOT NULL,
    alternative SMALLINT   REFERENCES AlternativeDesignation(alternative)

    -- Coordinates information (III, pg 15 in the Codebook)
    latitude    REAL       NOT NULL,
    longitude   REAL       NOT NULL,
    Foreign key (latitude, longitude) REFERENCES Coordinates(latitude, longitude),

    -- Attack information (IV, pg 21 in the Codebook)
    success     BOOLEAN    NOT NULL,
    suicide     BOOLEAN    NOT NULL,

    -- Weapon Information (V, pg 29-30 in the Codebook)
    weapdetail  TEXT,

    -- Perpetrator Information (VII, pg 40 in Codebook)
    nperps     SMALLINT    NOT NULL,
    nperpcap   SMALLINT    NOT NULL,
    compclaim  SMALLINT,
    motive     TEXT,

    --  Casualties and Consequences (VIII, pg 46 in Codebook)
    nkill      REAL, 
    nkillus    REAL,
    nkillter   REAL,
    nwound     REAL,
    nwoundus   REAL,
    nwoundte   REAL,

    property   SMALLINT    NOT NULL,
    ishostkid  SMALLINT    NOT NULL,

    -- Additional Information and Sources (IX, pg 54 on Codebook)
    addnotes   TEXT,
    INT_LOG    SMALLINT    NOT NULL,
    INT_IDEO   SMALLINT    NOT NULL,
    INT_MISC   SMALLINT    NOT NULL,
    INT_ANY    SMALLINT    NOT NULL,
    dbsource   TEXT
);
------------------------------------------------------------------------

CREATE TABLE Attack
(
    attacktype     SMALLINT     PRIMARY KEY,
    attacktype_txt TEXT NOT NULL UNIQUE
);


CREATE TABLE EventAttack
(
    eventid    BIGINT   NOT NULL REFERENCES GTD(eventid),
    attack_seq SMALLINT NOT NULL,
    PRIMARY KEY (eventid, attack_seq),
    attacktype SMALLINT NOT NULL REFERENCES Attack(attacktype)
);

-- Target/Victim Information (VI, pg 30 on Codebook)

CREATE TABLE TargetType
(
    targettype     SMALLINT     PRIMARY KEY,
    targettype_txt TEXT NOT NULL UNIQUE
);

CREATE TABLE TargetSubType
(
    targetsubtype     SMALLINT     PRIMARY KEY,
    targetsubtype_txt TEXT NOT NULL UNIQUE,
    targettype        SMALLINT     NOT NULL REFERENCES TargetType(targettype)
);

CREATE TABLE EventTarget
(
    eventid       BIGINT   NOT NULL REFERENCES GTD(eventid),
    target_seq    SMALLINT NOT NULL,
    PRIMARY KEY (eventid, target_seq),
    targettype    SMALLINT NOT NULL REFERENCES TargetType(targettype),
    targetsubtype SMALLINT REFERENCES TargetSubType(targetsubtype),
    natlty        SMALLINT REFERENCES Country(country),
    corp          TEXT,
    target        TEXT
);
----------------------------------------------------------------------

-- Weapon Information (V, pg 26 in the Codebook) 

CREATE TABLE WeaponType
(
    weaptype     SMALLINT     PRIMARY KEY,
    weaptype_txt TEXT NOT NULL UNIQUE
);

CREATE TABLE WeaponSubType
(
    weapsubtype      SMALLINT     PRIMARY KEY,
    weapsubtype_text TEXT         NOT NULL UNIQUE,
    weaptype         SMALLINT     NOT NULL REFERENCES WeaponType(weaptype)
);

CREATE TABLE EventWeapon
(
    eventid     BIGINT          NOT NULL REFERENCES GTD(eventid),
    weapon_seq  SMALLINT        NOT NULL,
    PRIMARY KEY (eventid, weapon_seq),
    weaptype    SMALLINT        NOT NULL REFERENCES WeaponType(weaptype),
    weapsubtype SMALLINT        REFERENCES WeaponSubType(weapsubtype)
);

-- Relation Table
CREATE TABLE RelatedIncident
(
    eventid1 BIGINT NOT NULL REFERENCES GTD(eventid),
    eventid2 BIGINT NOT NULL REFERENCES GTD(eventid),
    PRIMARY KEY (eventid1, eventid2)
);

-- PERPETRATOR TABLE
CREATE TABLE ClaimMode
(
    claimmode     SMALLINT     PRIMARY KEY,
    claimmode_txt TEXT NOT NULL UNIQUE
);

CREATE TABLE EventPerpetrator
(
    eventid    BIGINT       NOT NULL REFERENCES GTD(eventid),
    perp_seq   SMALLINT     NOT NULL,
    PRIMARY KEY (eventid, perp_seq),
    gname      TEXT     NOT NULL,
    gsubname   TEXT,
    guncertain1 BOOLEAN      NOT NULL,
    guncertain2 BOOLEAN, 
    guncertain3 BOOLEAN,   
    claim      BOOLEAN,
    claimmode  SMALLINT     REFERENCES ClaimMode(claimmode)
);

-- Casualties and Consequences (VIII, pg 46 in the codebook)

CREATE TABLE HostkidOutcome
(
    hostkidoutcome     SMALLINT     PRIMARY KEY,
    hostkidoutcome_txt TEXT NOT NULL UNIQUE
);


CREATE TABLE PropertyExtent
(
    propextent     SMALLINT     PRIMARY KEY,
    propextent_txt TEXT NOT NULL UNIQUE
);


CREATE TABLE PropertyDetails
(
    eventid     BIGINT   NOT NULL REFERENCES GTD(eventid),
    propextent  SMALLINT NOT NULL REFERENCES PropertyExtent(propextent),
    propvalue   REAL,
    propcomment TEXT,
    PRIMARY KEY (eventid)
);

CREATE TABLE HostageDetails
(
    eventid        BIGINT       NOT NULL REFERENCES GTD(eventid),
    nhostkid       REAL         NOT NULL,
    nhostkidus     REAL         NOT NULL,
    nhours         REAL,
    ndays          REAL,
    divert         TEXT REFERENCES Country(country_txt),
    kidhijcountry  TEXT REFERENCES Country(country_txt),
    ransom         SMALLINT     NOT NULL,
    hostkidoutcome SMALLINT     NOT NULL REFERENCES HostkidOutcome(hostkidoutcome),
    nreleased      REAL         NOT NULL,
    ransomnote     TEXT,
    PRIMARY KEY (eventid)
);

CREATE TABLE RansomDetails
(
    eventid      BIGINT   NOT NULL REFERENCES HostageDetails(eventid),
    ransomus     SMALLINT NOT NULL,
    ransomamt    REAL     NOT NULL,
    ransomamtus  REAL,
    ransompaid   REAL,
    ransompaidus REAL,

    PRIMARY KEY (eventid)
);

CREATE TABLE EventSourceCitation
(
    eventid      BIGINT   NOT NULL REFERENCES GTD(eventid),
    citation_seq SMALLINT NOT NULL,
    scite        TEXT     NOT NULL,
    PRIMARY KEY(eventid, citation_seq)
);


-------------------------------------------------------------------
-------------------------------------------------------------------
-- Homework 1 Problem 2
-- Rewrite of the queries for normalized schema

-- Original 1) 
-- select eventid, iyear from GTD where region_text like '%Africa'

WITH EVERYTHING AS 
(
    SELECT *
    FROM  GTD NATURAL JOIN Coordinates NATURAL JOIN Country NATURAL JOIN Region
)
SELECT eventid, iyear
FROM   EVERYTHING
WHERE  region_txt LIKE '%Africa';

-- Original 2) 
-- select iday, imonth, iyear, city, country_txt from GTD where nkill > 5 and weapdetail like '%bomb%'
-- 2)

WITH QUES2 AS 
(
    SELECT *
    FROM GTD NATURAL JOIN Coordinates NATURAL JOIN Country
)

SELECT iday, imonth, iyear, city, country_txt FROM QUES2 WHERE nkill > 5 AND weapdetail LIKE '%bomb%';

-- Original 3) 
-- select G1.eventid, G2.eventid from GTD G1, GTD G2 where G1.eventid <> G2.eventid and G1.iday = G2.iday and G1.imonth = G2.imonth and G1.iyear = G2.iyear and G1.country = G2.country and G1.weaptype1 = G2.weaptype1
-- 3)
WITH EVENT AS
(
    SELECT eventid, iday, imonth, iyear, country, weaptype
    FROM   GTD NATURAL JOIN EventWeapon NATURAL JOIN Coordinates
    WHERE  weapon_seq = 1
)
SELECT T1.eventid, T2.eventid
FROM   EVENT T1, EVENT T2
WHERE  T1.eventid != T2.eventid AND
       T1.iday = T2.iday AND
       T1.imonth = T2.imonth AND
       T1.iyear = T2.iyear AND
       T1.country = T2.country AND
       T1.weaptype = T2.weaptype;

-- Original 4) 
-- select eventid from GTD where targtype1 = 2 or targtype2 = 2
-- 4)
SELECT eventid
FROM   EventTarget
WHERE  (target_seq = 1 OR target_seq = 2) AND targettype = 2;

-- Original 5) 
-- select summary from GTD where country_txt = 'Afghanistan' and motive is not null
-- 5)
WITH EVENT_Terror as
(
    SELECT summary
    FROM   GTD NATURAL JOIN Coordinates NATURAL JOIN Country
    WHERE  country_txt = 'Afghanistan' AND motive IS NOT NULL
)

SELECT summary
FROM   EVENT_Terror;

