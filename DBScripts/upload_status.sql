SET DEFINE OFF

DECLARE
   dosent_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (dosent_exist, -02289);
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE upload_status_seq';
EXCEPTION
   WHEN dosent_exist
   THEN
      NULL;
END;
/

DECLARE
   dosent_exist   EXCEPTION;
   PRAGMA EXCEPTION_INIT (dosent_exist, -00942);
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE upload_status CASCADE CONSTRAINTS';
EXCEPTION
   WHEN dosent_exist
   THEN
      NULL;
END;
/

CREATE SEQUENCE upload_status_seq;

CREATE TABLE upload_status
(
   upload_status_id        NUMBER NOT NULL
  ,upload_file_id         NUMBER
  ,file_path              VARCHAR2 (4000 BYTE)
  ,file_name              VARCHAR2 (4000 BYTE)
  ,status_id              NUMBER DEFAULT 1 
  ,progress               VARCHAR2 (4000 BYTE) 
  ,max_rows               NUMBER
  ,rows_processed         NUMBER
  ,created_by             VARCHAR2 (100 BYTE) NOT NULL
  ,created_on             DATE NOT NULL
  ,last_updated_by        VARCHAR2 (100 BYTE)
  ,last_updated_on        DATE
  ,PRIMARY KEY (upload_status_id)
);


CREATE OR REPLACE TRIGGER upload_status_bi
   BEFORE INSERT
   ON upload_status
   REFERENCING NEW AS new OLD AS old
   FOR EACH ROW
BEGIN
   IF :new.upload_status_id IS NULL
   THEN
      :new.upload_status_id := upload_status_seq.NEXTVAL;
   END IF;

   :new.created_by := NVL (v ('APP_USER'), USER);
   :new.created_on := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER upload_status_bu
   BEFORE UPDATE
   ON upload_status
   FOR EACH ROW
BEGIN
   :new.last_updated_by := NVL (v ('APP_USER'), USER);
   :new.last_updated_on := SYSDATE;
END;
/