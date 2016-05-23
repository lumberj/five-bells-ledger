CREATE SEQUENCE seq_l_account_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE seq_l_entries_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE seq_l_fulfillments_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE seq_l_notifications_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  NOCACHE
  ORDER;

CREATE SEQUENCE seq_l_subscriptions_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE seq_l_transfers_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

CREATE SEQUENCE seq_l_trnsfr_adj_pk
  INCREMENT BY 1
  START WITH 1
  NOCYCLE
  CACHE 100
  ORDER;

--
-- create table
--


CREATE TABLE "accounts"
(
  "account_id"           INTEGER  NOT NULL ,
  "name"                 VARCHAR2(255) NOT NULL ,
  "balance"              NUMBER(32,16) NULL ,
  "connector"            VARCHAR2(1024) NULL ,
  "password_hash"        VARCHAR2(255) NULL ,
  "public_key"           VARCHAR2(4000) NULL ,
  "is_admin"             SMALLINT NULL ,
  "is_disabled"          SMALLINT NULL ,
  "fingerprint"          INTEGER NULL ,
  "minimum_allowed_balance" NUMBER(32,16) DEFAULT  0  NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKACCOUNTS ON "accounts"
("account_id"   ASC);

ALTER TABLE "accounts"
  ADD CONSTRAINT  PK_ACCOUNTS PRIMARY KEY ("account_id");

CREATE UNIQUE INDEX XAK1ACCOUNTS ON "accounts"
("name"   ASC);

ALTER TABLE "accounts"
ADD CONSTRAINT  XAK1_ACCOUNTS UNIQUE ("name");

CREATE INDEX XIE1_FINGERPRINTS ON "accounts"
("fingerprint"   ASC);

CREATE TABLE L_LU_REJECTION_REASON
(
  REJECTION_REASON_ID  INTEGER NOT NULL ,
  REJECTION_REASON_CODE VARCHAR2(10) NOT NULL ,
  REJECTION_REASON_DESC VARCHAR2(255) NULL ,
  DB_CREATED_DTTM      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_LU_TRANSFERS_REJECTION_RE ON L_LU_REJECTION_REASON
(REJECTION_REASON_ID   ASC);

ALTER TABLE L_LU_REJECTION_REASON
  ADD CONSTRAINT  PK_LU_TRANSFERS_REJECTION_REAS PRIMARY KEY (REJECTION_REASON_ID);

CREATE INDEX XAK1L_LU_TRANSFERS_REJECTION_R ON L_LU_REJECTION_REASON
(REJECTION_REASON_CODE   ASC);

ALTER TABLE L_LU_REJECTION_REASON
ADD CONSTRAINT  XAK1LU_TRANSFERS_RJCTN_RSN UNIQUE (REJECTION_REASON_CODE);

CREATE TABLE L_LU_TRANSFERS_STATUS
(
  STATUS_ID            INTEGER NOT NULL ,
  STATUS_CODE          VARCHAR2(20) NOT NULL ,
  STATUS_DESC          VARCHAR2(255) NULL ,
  DB_CREATED_DTTM      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_DTTM      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  DB_UPDATED_USER      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_LU_TRANSFERS_STATUS ON L_LU_TRANSFERS_STATUS
(STATUS_ID   ASC);

ALTER TABLE L_LU_TRANSFERS_STATUS
  ADD CONSTRAINT  PK_LU_TRANSFERS_STATUS PRIMARY KEY (STATUS_ID);

CREATE INDEX XAK1L_LU_TRANSFERS_STATUS ON L_LU_TRANSFERS_STATUS
(STATUS_CODE   ASC);

ALTER TABLE L_LU_TRANSFERS_STATUS
ADD CONSTRAINT  AK1_LU_TRANSFERS_STATUS UNIQUE (STATUS_CODE);

CREATE TABLE "subscriptions"
(
  "subscription_id"      INTEGER  NOT NULL ,
  "subscription_uuid"    VARCHAR2(64) NOT NULL ,
  "owner_id"             INTEGER NOT NULL ,
  "event"                VARCHAR2(255) DEFAULT  NULL  NULL ,
  "subject_id"           INTEGER NOT NULL ,
  "target"               VARCHAR2(4000) DEFAULT  NULL  NULL ,
  "is_deleted"           SMALLINT NOT NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_SUBSCRIPTIONS ON "subscriptions"
("subscription_id" ASC);

ALTER TABLE "subscriptions"
  ADD CONSTRAINT  PK_SUBSCRIPTIONS PRIMARY KEY ("subscription_id");

CREATE UNIQUE INDEX XAK1L_SUBSCRIPTIONS ON "subscriptions"
("subscription_uuid"   ASC);

ALTER TABLE "subscriptions"
ADD CONSTRAINT  XAK1_SUBSCRIPTIONS UNIQUE ("subscription_uuid");

CREATE INDEX XIF1L_SUBSCRIPTIONS ON "subscriptions"
("owner_id"   ASC);

CREATE INDEX XIF2L_SUBSCRIPTIONS ON "subscriptions"
("subject_id"   ASC);

CREATE INDEX XIE1L_SUBSCRIPTIONS ON "subscriptions"
("is_deleted" ASC);

CREATE TABLE "transfers"
(
  "transfer_id"          INTEGER  NOT NULL ,
  "transfer_uuid"        VARCHAR2(64) NOT NULL ,
  "ledger"               VARCHAR2(1024) NULL ,
  "status_id"            INTEGER NOT NULL ,
  "rejection_reason_id"  INTEGER NOT NULL ,
  "additional_info"      VARCHAR2(4000) NULL ,
  "execution_condition"  VARCHAR2(4000) NULL ,
  "cancellation_condition" VARCHAR2(4000) NULL ,
  "expires_dttm"         TIMESTAMP NULL ,
  "proposed_dttm"        TIMESTAMP NULL ,
  "prepared_dttm"        TIMESTAMP NULL ,
  "executed_dttm"        TIMESTAMP NULL ,
  "rejected_dttm"        TIMESTAMP NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_TRANSFERS ON "transfers"
("transfer_id"   ASC);

ALTER TABLE "transfers"
  ADD CONSTRAINT  PK_TRANSFERS PRIMARY KEY ("transfer_id");

CREATE INDEX XAK1L_TRANSFERS ON "transfers"
("transfer_uuid"   ASC);

ALTER TABLE "transfers"
ADD CONSTRAINT  AK1_TRANSFERS UNIQUE ("transfer_uuid");

-- Not available on Oracle XE

-- CREATE BITMAP INDEX XIF1L_TRANSFERS ON "transfers"
-- (STATUS_ID   ASC);
--
-- CREATE BITMAP INDEX XIF2L_TRANSFERS ON "transfers"
-- (REJECTION_REASON_ID   ASC);

CREATE TABLE "entries"
(
  "entry_id"             INTEGER  NOT NULL ,
  "transfer_id"          INTEGER NULL ,
  "account_id"           INTEGER NULL ,
  "entry_balance"        NUMBER(32,16) DEFAULT  0  NOT NULL ,
  "created_at"           TIMESTAMP NOT NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_ENTRIES ON "entries"
("entry_id"   ASC);

ALTER TABLE "entries"
  ADD CONSTRAINT  PK_ENTRIES PRIMARY KEY ("entry_id");

CREATE UNIQUE INDEX XAK1L_ENTRIES ON "entries"
("transfer_id"   ASC,"account_id"   ASC);

ALTER TABLE "entries"
ADD CONSTRAINT  XAK1L_ENTRIES UNIQUE ("transfer_id","account_id");

CREATE INDEX XIF2L_ENTRIES ON "entries"
("account_id"   ASC);

CREATE INDEX XIF3L_ENTRIES ON "entries"
("transfer_id"   ASC);

CREATE INDEX XIE1L_ENTRIES ON "entries"
("created_at"   ASC);

CREATE TABLE "fulfillments"
(   "fulfillment_id"       INTEGER NOT NULL ,
  "transfer_id"          INTEGER NOT NULL ,
  "condition_fulfillment" VARCHAR2(4000) NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_FULFILLMENTS ON "fulfillments"
("fulfillment_id"   ASC);

ALTER TABLE "fulfillments"
  ADD CONSTRAINT  PK_FULFILLMENTS PRIMARY KEY ("fulfillment_id");

CREATE INDEX XIF1L_FULFILLMENTS ON "fulfillments"
("transfer_id"   ASC);

CREATE TABLE "notifications"
(
  "notification_id"      INTEGER  NOT NULL ,
  "notification_uuid"    VARCHAR2(64) NOT NULL ,
  "subscription_id"      INTEGER NOT NULL ,
  "transfer_id"          INTEGER NOT NULL ,
  "retry_count"          INTEGER DEFAULT  0  NULL ,
  "retry_at"             TIMESTAMP ,
  "is_delivered"         SMALLINT NOT NULL ,
  "is_deleted"           SMALLINT NOT NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);

CREATE INDEX XPKL_NOTIFICATIONS ON "notifications"
("notification_id"   ASC);

ALTER TABLE "notifications"
  ADD CONSTRAINT  PK_NOTIFICATIONS PRIMARY KEY ("notification_id");

CREATE INDEX XAK1L_NOTIFICATIONS ON "notifications"
("notification_uuid"   ASC);

ALTER TABLE "notifications"
ADD CONSTRAINT  AK1_NOTIFICATIONS UNIQUE ("notification_uuid");

CREATE INDEX XIE2NOTIFICATIONS_RETRY_DATETI ON "notifications"
("retry_at"   ASC);

CREATE INDEX XIF1L_NOTIFICATIONS ON "notifications"
("subscription_id"   ASC);

CREATE INDEX XIF2L_NOTIFICATIONS ON "notifications"
("transfer_id"   ASC);

CREATE INDEX XIE3L_NOTIFICATIONS ON "notifications"
("is_deleted"   ASC);

CREATE TABLE "transfer_adjustments"
(
  "transfer_adjustment_id" INTEGER  NOT NULL ,
  "transfer_id"          INTEGER NOT NULL ,
  "account_id"           INTEGER NOT NULL ,
  "debit_credit"         VARCHAR2(10) NOT NULL ,
  "amount"               NUMBER(32,16) DEFAULT  0  NULL ,
  "is_authorized"        SMALLINT NOT NULL ,
  "memo"                 VARCHAR2(4000) NULL ,
  "db_updated_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_created_dttm"      TIMESTAMP DEFAULT  sysdate  NOT NULL ,
  "db_updated_user"      VARCHAR2(40) DEFAULT  USER  NOT NULL
);


CREATE INDEX XPKL_TRANSFER_ADJUSTMENTS ON "transfer_adjustments"
("transfer_adjustment_id"   ASC);

ALTER TABLE "transfer_adjustments"
  ADD CONSTRAINT  PK_TRANSFER_ADJUSTMENTS PRIMARY KEY ("transfer_adjustment_id");

CREATE UNIQUE INDEX XAK1L_TRANSFER_ADJUSTMENTS ON "transfer_adjustments"
("transfer_id"   ASC,"account_id"   ASC);

ALTER TABLE "transfer_adjustments"
ADD CONSTRAINT  XAK1L_TRANSFER_ADJUSTMENTS UNIQUE ("transfer_id","account_id");

CREATE INDEX XIF1L_TRANSFER_ADJUSTMENTS ON "transfer_adjustments"
("transfer_id"   ASC);

CREATE INDEX XIF2L_TRANSFER_ADJUSTMENTS ON "transfer_adjustments"
("account_id"   ASC);

CREATE INDEX XIE1L_TRANSFER_ADJUSTMENTS ON "transfer_adjustments"
("is_authorized"   ASC);


--
--  Additioanl Constraints
--


ALTER TABLE "subscriptions"
  ADD (CONSTRAINT FK_OWNER_ID__ACCOUNTS FOREIGN KEY ("owner_id") REFERENCES "accounts" ("account_id") ON DELETE SET NULL);

ALTER TABLE "subscriptions"
  ADD (CONSTRAINT FK_SUBJECT_ID__ACCOUNTS FOREIGN KEY ("subject_id") REFERENCES "accounts" ("account_id") ON DELETE SET NULL);

ALTER TABLE "transfers"
  ADD (CONSTRAINT FK_STATUS_ID__TRANSFERS FOREIGN KEY ("status_id") REFERENCES L_LU_TRANSFERS_STATUS (STATUS_ID) ON DELETE SET NULL);

ALTER TABLE "transfers"
  ADD (CONSTRAINT FK_REJECTION_REASON_ID__TRANSF FOREIGN KEY ("rejection_reason_id") REFERENCES L_LU_REJECTION_REASON (REJECTION_REASON_ID) ON DELETE SET NULL);

ALTER TABLE "entries"
  ADD (CONSTRAINT FK_ACCOUNT_ID__ENTRIES FOREIGN KEY ("account_id") REFERENCES "accounts" ("account_id") ON DELETE SET NULL);

ALTER TABLE "entries"
  ADD (CONSTRAINT FK_TRANSFER_ID__ENTRIES FOREIGN KEY ("transfer_id") REFERENCES "transfers" ("transfer_id") ON DELETE SET NULL);

ALTER TABLE "fulfillments"
  ADD (CONSTRAINT FK_TRANSFER_ID__TRANSFERS FOREIGN KEY ("transfer_id") REFERENCES "transfers" ("transfer_id") ON DELETE SET NULL);

ALTER TABLE "notifications"
  ADD (CONSTRAINT FK_SUBSCRIPTIONS_ID__NOTIFICAT FOREIGN KEY ("subscription_id") REFERENCES "subscriptions" ("subscription_id") ON DELETE SET NULL);

ALTER TABLE "notifications"
  ADD (CONSTRAINT FK_TRANSFER_ID__NOTIFICATIONS FOREIGN KEY ("transfer_id") REFERENCES "transfers" ("transfer_id") ON DELETE SET NULL);

ALTER TABLE "transfer_adjustments"
  ADD (CONSTRAINT FK_TRANSFER_ID__TRANSFER_DETAI FOREIGN KEY ("transfer_id") REFERENCES "transfers" ("transfer_id"));

ALTER TABLE "transfer_adjustments"
  ADD (CONSTRAINT FK_ACCOUNTS_ID__TRANSFER_DETAI FOREIGN KEY ("account_id") REFERENCES "accounts" ("account_id") ON DELETE SET NULL);


--
-- Triggers
--

CREATE OR REPLACE TRIGGER trg_ACCOUNTS_SEQ
  BEFORE INSERT
  ON "accounts"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."account_id" is null)
DECLARE
  v_id "accounts"."account_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new."account_id"
  SELECT seq_l_account_pk.nextval INTO v_id FROM DUAL;

  :new."account_id" := v_id;
END trg_ACCOUNTS_SEQ;


CREATE OR REPLACE TRIGGER trg_L_SUBSCRIPTIONS_SEQ
  BEFORE INSERT
  ON "subscriptions"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."subscription_id" is null)
DECLARE
  v_id "subscriptions"."subscription_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.SUBSCRIPTION_ID
  SELECT seq_l_subscriptions_pk.nextval INTO v_id FROM DUAL;

  :new."subscription_id" := v_id;
END trg_L_SUBSCRIPTIONS_SEQ;


CREATE OR REPLACE TRIGGER trg_L_TRANSFERS_SEQ
  BEFORE INSERT
  ON "transfers"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."transfer_id" is null)
DECLARE
  v_id "transfers"."transfer_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new."transfer_id"
  SELECT seq_l_transfers_pk.nextval INTO v_id FROM DUAL;

  :new."transfer_id" := v_id;
END trg_L_TRANSFERS_SEQ;


CREATE OR REPLACE TRIGGER trg_L_ENTRIES_SEQ
  BEFORE INSERT
  ON "entries"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."entry_id" is null)
DECLARE
  v_id "entries"."entry_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.ENTRY_ID
  SELECT seq_l_entries_pk.nextval INTO v_id FROM DUAL;

  :new."entry_id" := v_id;
END trg_L_ENTRIES_SEQ;


CREATE OR REPLACE TRIGGER trg_L_FULFILLMENTS_SEQ
  BEFORE INSERT
  ON "fulfillments"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."fulfillment_id" is null)
DECLARE
  v_id "fulfillments"."fulfillment_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.FULFILLMENT_ID
  SELECT seq_l_fulfillments_pk.nextval INTO v_id FROM DUAL;

  :new."fulfillment_id" := v_id;
END trg_L_FULFILLMENTS_SEQ;


CREATE OR REPLACE TRIGGER trg_L_NOTIFICATIONS_SEQ
  BEFORE INSERT
  ON "notifications"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."notification_id" is null)
DECLARE
  v_id "notifications"."notification_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new.NOTIFICATION_ID
  SELECT seq_L_NOTIFICATIONS_pk.nextval INTO v_id FROM DUAL;

  :new."notification_id" := v_id;
END trg_L_NOTIFICATIONS_SEQ;



CREATE OR REPLACE TRIGGER trg_L_TRANSFER_ADJUSTMENTS_SEQ
  BEFORE INSERT
  ON "transfer_adjustments"
  FOR EACH ROW
  -- Optionally restrict this trigger to fire only when really needed
  WHEN (new."transfer_adjustment_id" is null)
DECLARE
  v_id "transfer_adjustments"."transfer_adjustment_id"%TYPE;
BEGIN
  -- Select a new value from the sequence into a local variable. As David
  -- commented, this step is optional. You can directly select into :new."transfer_adjustment_id"
  SELECT seq_l_trnsfr_adj_pk.nextval INTO v_id FROM DUAL;

  :new."transfer_adjustment_id" := v_id;
END trg_L_TRANSFER_ADJUSTMENTS_SEQ;






CREATE OR REPLACE TRIGGER trg_ACCOUNTS_update
BEFORE UPDATE
   ON  "accounts"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_ACCOUNTS_insert
BEFORE INSERT
   ON  "accounts"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/


CREATE OR REPLACE TRIGGER trg_L_SUBSCRIPTIONS_update
BEFORE UPDATE
   ON  "subscriptions"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_SUBSCRIPTIONS_insert
BEFORE INSERT
   ON  "subscriptions"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/


CREATE OR REPLACE TRIGGER trg_L_TRANSFERS_update
BEFORE UPDATE
   ON  "transfers"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_TRANSFERS_insert
BEFORE INSERT
   ON  "transfers"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/


CREATE OR REPLACE TRIGGER trg_L_ENTRIES_update
BEFORE UPDATE
   ON  "entries"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_ENTRIES_insert
BEFORE INSERT
   ON  "entries"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/


CREATE OR REPLACE TRIGGER trg_L_FULFILLMENTS_update
BEFORE UPDATE
   ON  "fulfillments"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_FULFILLMENTS_insert
BEFORE INSERT
   ON  "fulfillments"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/



CREATE OR REPLACE TRIGGER trg_L_NOTIFICATIONS_update
BEFORE UPDATE
   ON  "notifications"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_NOTIFICATIONS_insert
BEFORE INSERT
   ON  "notifications"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/


CREATE OR REPLACE TRIGGER trg_L_TRNSFR_ADJMNTS_update
BEFORE UPDATE
   ON  "transfer_adjustments"
   FOR EACH ROW
BEGIN
   -- Update db_updated_dttm field to current system date
   :new."db_updated_dttm" := SYSDATE;
   :new."db_updated_user" := USER;
END;
/

CREATE OR REPLACE TRIGGER trg_L_TRNSFR_ADJMNTS_insert
BEFORE INSERT
   ON  "transfer_adjustments"
   FOR EACH ROW
BEGIN
   -- Update db_created_dttm field to current system date
   :new."db_created_dttm" := sysdate;
END;
/

--
-- Synonyms
--


CREATE PUBLIC SYNONYM "accounts"
   FOR "accounts";

CREATE PUBLIC SYNONYM "entries"
   FOR "entries";

CREATE PUBLIC SYNONYM "fulfillments"
   FOR "fulfillments";

CREATE PUBLIC SYNONYM L_LU_REJECTION_REASON
   FOR L_LU_REJECTION_REASON;

CREATE PUBLIC SYNONYM L_LU_TRANSFER_STATUS
   FOR L_LU_TRANSFER_STATUS;

CREATE PUBLIC SYNONYM "notifications"
   FOR "notifications";

CREATE PUBLIC SYNONYM "subscriptions"
   FOR "subscriptions";

CREATE PUBLIC SYNONYM "transfer_adjustments"
   FOR "transfer_adjustments";

CREATE PUBLIC SYNONYM "transfers"
   FOR "transfers";


--
--  Seed Lookup values
--

INSERT INTO L_LU_TRANSFERS_STATUS (STATUS_ID, STATUS_CODE) VALUES  (1, 'expired'    );
INSERT INTO L_LU_TRANSFERS_STATUS (STATUS_ID, STATUS_CODE) VALUES  (2, 'cancelled'  );
INSERT INTO L_LU_REJECTION_REASON (REJECTION_REASON_ID, REJECTION_REASON_CODE) VALUES (1, 'proposed'  );
INSERT INTO L_LU_REJECTION_REASON (REJECTION_REASON_ID, REJECTION_REASON_CODE) VALUES (2, 'prepared'  );
INSERT INTO L_LU_REJECTION_REASON (REJECTION_REASON_ID, REJECTION_REASON_CODE) VALUES (3, 'executed'  );
INSERT INTO L_LU_REJECTION_REASON (REJECTION_REASON_ID, REJECTION_REASON_CODE) VALUES (4, 'rejected'  );

