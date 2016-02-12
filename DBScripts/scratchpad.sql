CREATE OR REPLACE
PROCEDURE j_load_poi_demo_file(
    p_upload_file_id IN NUMBER)
AS
LANGUAGE JAVA NAME
   'com.arrow.ecs.portal.PoiDemo.processFile(oracle.sql.NUMBER)' ;



DECLARE
  P_FILE_PATH VARCHAR2(200);
  P_FILE_NAME VARCHAR2(200);
  P_UPLOAD_FILE_ID NUMBER;
BEGIN
  P_FILE_PATH := 'test';
  P_FILE_NAME := 'test';
  P_UPLOAD_FILE_ID := 2364308312157789;

  J_LOAD_POI_DEMO_FILE(
    P_FILE_PATH => P_FILE_PATH,
    P_FILE_NAME => P_FILE_NAME,
    P_UPLOAD_FILE_ID => P_UPLOAD_FILE_ID
  );
END;

delete from dept;
delete from upload_status;
delete from error_log;
commit;

select * from error_log

select * from wwv_flow_files


truncate table error_log