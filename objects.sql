BEGIN execute immediate 'drop table CORONAEXT PURGE';EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate 'drop table CORONA PURGE';EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN execute immediate 'drop table CORONA_ES PURGE';EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN DBMS_CLOUD.drop_CREDENTIAL(credential_name => 'CORONACRED');EXCEPTION WHEN OTHERS THEN NULL; END;
/
begin
    DBMS_CLOUD.CREATE_CREDENTIAL( credential_name => 'CORONACRED', username => 'alextorrijoserrano@gmail.com', password => 'm9G>(_vpWk4.c0Py}g}B');
    DBMS_CLOUD.CREATE_EXTERNAL_TABLE(   
      table_name =>'CORONAEXT',   
      credential_name =>'CORONACRED',   
      file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/freztbacphvb/b/corona/o/coronadata.txt',
      format => json_object('delimiter' value ',', 'recorddelimiter' value 'newline', 'skipheaders' value '1', 'rejectlimit' value '0'),

      column_list => 
            'dateRep varchar2(10), 
            day number,
            month number,
            year number,
            cases number,
            deaths number,
            countriesAndTerritories varchar2(128),
            geoId varchar2(32),
            countryterritoryCode varchar2(32),
            popData2018 number'
            );
    --
    DBMS_CLOUD.VALIDATE_EXTERNAL_TABLE ('CORONAEXT');
end;
/
select * from coronaext where rownum<3;
/
create table corona as select  to_date(dateRep,'dd/mm/yyyy') as fecha, deaths, cases, countryterritoryCode from coronaext;
/
create table corona_es as select fecha, deaths, cases, countryterritoryCode from corona where countryterritoryCode in ('ESP') order by fecha asc;
/
BEGIN execute immediate 'drop table CORONA_SETTINGS PURGE';EXCEPTION WHEN OTHERS THEN NULL; END;
/
begin
    execute immediate 'CREATE TABLE CORONA_SETTINGS  (	SETTING_NAME VARCHAR2(30 BYTE),  SETTING_VALUE VARCHAR2(4000 BYTE))';
    execute immediate 'Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values (''ALGO_NAME'',''ALGO_EXPONENTIAL_SMOOTHING'')';
    execute immediate 'Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values (''EXSM_MODEL'',''EXSM_MULT_TREND'')';
    execute immediate 'Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values (''EXSM_INTERVAL'',''EXSM_INTERVAL_DAY'')';
    execute immediate 'Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values (''EXSM_PREDICTION_STEP'',''20'')';
end;
/
BEGIN DBMS_DATA_MINING.DROP_MODEL('CORONA_ES_TS');
EXCEPTION WHEN OTHERS THEN NULL; END;
/
DECLARE
    --V_XLST DBMS_DATA_MINING_TRANSFORM.TRANSFORM_LIST;
BEGIN
    DBMS_DATA_MINING.CREATE_MODEL(
    MODEL_NAME          => 'CORONA_ES_TS',
    MINING_FUNCTION     => DBMS_DATA_MINING.TIME_SERIES,
    DATA_TABLE_NAME     => 'CORONA_ES',
    CASE_ID_COLUMN_NAME => 'FECHA',
    TARGET_COLUMN_NAME  => 'DEATHS',
    SETTINGS_TABLE_NAME => 'CORONA_SETTINGS',
    XFORM_LIST          => null);
END;
/
select case_id, value, prediction from DM$P0CORONA_ES_TS order by case_id asc;
/