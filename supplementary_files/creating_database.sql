-- Creating Summary

DROP TABLE IF EXISTS summary CASCADE;

CREATE TABLE summary (
  Cust_ID           int       PRIMARY KEY,
  SCF_Code          varchar,
  RetF07Dollars     numeric,
  RetF07Trips       numeric,
  RetF07Lines       numeric,
  RetS07Dollars     numeric,
  RetS07Trips       numeric,
  RetS07Lines       numeric,
  RetF06Dollars     numeric,
  RetF06Trips       numeric,
  RetF06Lines       numeric,
  RetS06Dollars     numeric,
  RetS06Trips       numeric,
  RetS06Lines       numeric,
  RetF05Dollars     numeric,
  RetF05Trips       numeric,
  RetF05Lines       numeric,
  RetS05Dollars     numeric,
  RetS05Trips       numeric,
  RetS05Lines       numeric,
  RetF04Dollars     numeric,
  RetF04Trips       numeric,
  RetF04Lines       numeric,
  RetS04Dollars     numeric,
  RetS04Trips       numeric,
  RetS04Lines       numeric,
  RetPre04Dollars   numeric,
  RetPre04Trips     numeric,
  RetPre04Lines     numeric,
  RetPre04Recency   numeric,
  IntF07GDollars    numeric,
  IntF07NGDollars   numeric,
  IntF07Orders      numeric,
  IntF07Lines       numeric,
  IntS07GDollars    numeric,
  IntS07NGDollars   numeric,
  IntS07Orders      numeric,
  IntS07Lines       numeric,
  IntF06GDollars    numeric,
  IntF06NGDollars   numeric,
  IntF06Orders      numeric,
  IntF06Lines       numeric,
  IntS06GDollars    numeric,
  IntS06NGDollars   numeric,
  IntS06Orders      numeric,
  IntS06Lines       numeric,
  IntF05GDollars    numeric,
  IntF05NGDollars   numeric,
  IntF05Orders      numeric,
  IntF05Lines       numeric,
  IntS05GDollars    numeric,
  IntS05NGDollars   numeric,
  IntS05Orders      numeric,
  IntS05Lines       numeric,
  IntF04GDollars    numeric,
  IntF04NGDollars   numeric,
  IntF04Orders      numeric,
  IntF04Lines       numeric,
  IntS04GDollars    numeric,
  IntS04NGDollars   numeric,
  IntS04Orders      numeric,
  IntS04Lines       numeric,
  IntPre04GDollars  numeric,
  IntPre04NGDollars numeric,
  IntPre04Orders    numeric,
  IntPre04Lines     numeric,
  IntPre04Recency   numeric,
  CatF07GDollars    numeric,
  CatF07NGDollars   numeric,
  CatF07Orders      numeric,
  CatF07Lines       numeric,
  CatS07GDollars    numeric,
  CatS07NGDollars   numeric,
  CatS07Orders      numeric,
  CatS07Lines       numeric,
  CatF06GDollars    numeric,
  CatF06NGDollars   numeric,
  CatF06Orders      numeric,
  CatF06Lines       numeric,
  CatS06GDollars    numeric,
  CatS06NGDollars   numeric,
  CatS06Orders      numeric,
  CatS06Lines       numeric,
  CatF05GDollars    numeric,
  CatF05NGDollars   numeric,
  CatF05Orders      numeric,
  CatF05Lines       numeric,
  CatS05GDollars    numeric,
  CatS05NGDollars   numeric,
  CatS05Orders      numeric,
  CatS05Lines       numeric,
  CatF04GDollars    numeric,
  CatF04NGDollars   numeric,
  CatF04Orders      numeric,
  CatF04Lines       numeric,
  CatS04GDollars    numeric,
  CatS04NGDollars   numeric,
  CatS04Orders      numeric,
  CatS04Lines       numeric,
  CatPre04GDollars  numeric,
  CatPre04NGDollars numeric,
  CatPre04Orders    numeric,
  CatPre04Lines     numeric,
  CatPre04Recency   numeric,
  EmailsF07         numeric,
  EmailsS07         numeric,
  EmailsF06         numeric,
  EmailsS06         numeric,
  EmailsF05         numeric,
  EmailsS05         numeric,
  CatCircF07        numeric,
  CatCircS07        numeric,
  CatCircF06        numeric,
  CatCircS06        numeric,
  CatCircF05        numeric,
  CatCircS05        numeric,
  GiftRecF07        numeric,
  GiftRecS07        numeric,
  GiftRecF06        numeric,
  GiftRecS06        numeric,
  GiftRecF05        numeric,
  GiftRecS05        numeric,
  GiftRecF04        numeric,
  GiftRecS04        numeric,
  GiftRecPre04      numeric,
  NewGRF07          numeric,
  NewGRS07          numeric,
  NewGRF06          numeric,
  NewGRS06          numeric,
  NewGRF05          numeric,
  NewGRS05          numeric,
  NewGRF04          numeric,
  NewGRS04          numeric,
  NewGRPre04        numeric,
  FirstYYMM         date,
  FirstChannel      text,
  FirstDollar       numeric,
  StoreDist         decimal,
  AcqDate           date,
  Email             boolean,
  OccupCd           varchar,
  Travel            varchar,
  CurrAff           varchar,
  CurrEv            varchar,
  Wines             varchar,
  FineArts          varchar,
  Exercise          varchar,
  SelfHelp          varchar,
  Collect           varchar,
  Needle            varchar,
  Sewing            varchar,
  DogOwner          varchar,
  CarOwner          varchar,
  Cooking           varchar,
  Pets              varchar,
  Fashion           varchar,
  Camping           varchar,
  Hunting           varchar,
  Boating           varchar,
  AgeCode           varchar,
  IncCode           varchar,
  HomeCode          varchar,
  Child0_2          varchar,
  Child3_5          varchar,
  Child6_11         varchar,
  Child12_16        varchar,
  Child17_18        varchar,
  Dwelling          varchar,
  LengthRes         varchar,
  HomeValue         varchar
);

COPY summary
FROM '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/files/supplementary_files//cleaned_summary_01.CSV'
DELIMITER ','
CSV HEADER;

ALTER TABLE summary ADD column serial_no bigserial;

-- Creating Lines

DROP TABLE IF EXISTS lines CASCADE;

CREATE TABLE lines (
  Cust_ID           int          REFERENCES summary(Cust_ID),
  OrderNum          bigint,
  OrderDate         date,
  LineDollars       decimal,
  Gift              text,
  RecipNum          text
);

COPY lines
FROM '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/files/supplementary_files/DMEFExtractLinesV01.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE lines ADD column serial_no bigserial;

-- Creating Orders

DROP TABLE IF EXISTS orders CASCADE;

CREATE TABLE orders (
  Cust_ID           int            REFERENCES summary(Cust_ID),
  OrderNum          bigint         NOT NULL,
  OrderDate         date           NOT NULL,
  OrderMethod       text           NOT NULL,
  PaymentType       text           NOT NULL
  CONSTRAINT        OrderMethod_C  CHECK         (OrderMethod IN ('ST','I', 'P', 'M')),
  CONSTRAINT        PaymentType_C  CHECK         (PaymentType IN ('BC','CA', 'CK', 'GC', 'HA', 'NV', 'PC'))
);

COPY orders
FROM '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/files/supplementary_files/DMEFExtractOrdersV01.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE orders ADD column serial_no bigserial;

-- Creating Contacts

DROP TABLE IF EXISTS contacts CASCADE;

CREATE TABLE contacts (
  Cust_ID           int            REFERENCES summary(Cust_ID),
  ContactDate       date           NOT NULL,
  ContactType       varchar        NOT NULL
);

COPY contacts
FROM '/Users/avi/Dropbox/Users/Avi/MSc/modules/electives/Digital_Marketing_Analytics/w1/hw/group/files/supplementary_files/DMEFExtractContactsV01.csv'
DELIMITER ','
CSV HEADER;

ALTER TABLE contacts ADD column serial_no bigserial;
