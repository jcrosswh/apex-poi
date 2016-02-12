CREATE OR REPLACE
PACKAGE BODY POI_DEMO AS


  PROCEDURE ADD_HEAD_TO_COL(
      p_C001 VARCHAR2,
      p_C002 VARCHAR2,
      p_C003 VARCHAR2,
      p_C004 VARCHAR2,
      p_C005 VARCHAR2,
      p_C006 VARCHAR2,
      p_C007 VARCHAR2,
      p_C008 VARCHAR2) AS
  BEGIN
APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('PARSE_COL_HEAD');
APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C001'
,p_c002 => p_C001);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C002'
,p_c002 => p_C002);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C003'
,p_c002 => p_C003);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C004'
,p_c002 => p_C004);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C005'
,p_c002 => p_C005);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C006'
,p_c002 => p_C006);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C007'
,p_c002 => p_C007);

APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'PARSE_COL_HEAD'
,p_c001 => 'C008'
,p_c002 => p_C008);

  END ADD_HEAD_TO_COL;

  PROCEDURE ADD_SPREEDSHEET_DATA_TO_COL(
      p_apex_username VARCHAR2, 
      p_apex_session_id NUMBER,
      p_C001 VARCHAR2,
      p_C002 VARCHAR2,
      p_C003 VARCHAR2,
      p_C004 VARCHAR2,
      p_C005 VARCHAR2,
      p_C006 VARCHAR2,
      p_C007 VARCHAR2,
      p_C008 VARCHAR2,
      p_n001 NUMBER) AS
  BEGIN
  
    --Attach to session
      --Warning, unsupported feature
      APEX_UTIL.set_security_group_id (p_security_group_id => '2224912942262033');
      APEX_CUSTOM_AUTH.define_user_session (p_user         => p_apex_username
                                           ,p_session_id   => p_apex_session_id);
      APEX_APPLICATION.g_flow_id := 555;
      
      
  if p_n001 = 1 then
   APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION('SPREADSHEET_CONTENT');
   end if;
APEX_COLLECTION.ADD_MEMBER(
 p_collection_name => 'SPREADSHEET_CONTENT'
,p_c001 => p_C001
,p_c002 => p_C002
,p_c003 => p_C003
,p_c004 => p_C004
,p_c005 => p_C005
,p_c006 => p_C006
,p_c007 => p_C007
,p_c008 => p_C008
,p_n001 => p_n001);


  END ADD_SPREEDSHEET_DATA_TO_COL;

END POI_DEMO;