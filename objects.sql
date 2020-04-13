begin
    execute immediate 'drop table CORONA PURGE';
    DBMS_CLOUD.drop_CREDENTIAL(credential_name => 'CORONACRED');
    DBMS_CLOUD.CREATE_CREDENTIAL( credential_name => 'CORONACRED', username => 'sbnnogl', password => 'FyNe22(x_Q#s#9_Sx7[r');
    DBMS_CLOUD.CREATE_EXTERNAL_TABLE(   
      table_name =>'CORONA',   
      credential_name =>'CORONACRED',   
      file_uri_list => 'https://objectstorage.eu-frankfurt-1.oraclecloud.com/n/verisurenext/b/sbnnogl-incoming/o/corona*.txt',
      format => json_object('delimiter' value '|', 'skipheaders' value '1', 'rejectlimit' value '0'),
      column_list => '
            dateRep varchar2(10), 
            day number,
            month number,
            year number,
            cases number,
            deaths number,
            countriesAndTerritories varchar2(128),
            geoId varchar2(32),
            countryterritoryCode varchar2(32),
            popData2018 number
            ');
    --
    DBMS_CLOUD.VALIDATE_EXTERNAL_TABLE ('CORONA'); 
end;
/

CREATE TABLE "CORONA_SETTINGS"  (	"SETTING_NAME" VARCHAR2(30 BYTE) COLLATE "USING_NLS_COMP", 
	"SETTING_VALUE" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP");
Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values ('ALGO_NAME','ALGO_EXPONENTIAL_SMOOTHING');
Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values ('EXSM_MODEL','EXSM_SIMPLE');
Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values ('EXSM_INTERVAL','EXSM_INTERVAL_DAY');
Insert into CORONA_SETTINGS (SETTING_NAME,SETTING_VALUE) values ('EXSM_PREDICTION_STEP','20');