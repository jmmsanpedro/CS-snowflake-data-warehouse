USE ROLE ACCOUNTADMIN;
USE DATABASE SALES;
USE SCHEMA BRONZE;


--Create an external table that contains all values from all datasets in the blob

--CRM: cust_info files
CREATE OR REPLACE EXTERNAL TABLE CRM_CUST_INFO_EXT(
    CST_ID STRING as (value:c1::varchar),
	CST_KEY STRING as (value:c2::varchar),
	CST_FIRSTNAME STRING as (value:c3::varchar),
	CST_LASTNAME STRING as (value:c4::varchar),
	CST_MARITAL_STATUS STRING as (value:c5::varchar),
	CST_GNDR STRING as (value:c6::varchar),
	CST_CREATE_DATE DATE as (value:c7::date),
	CST_LOYALTY_JOIN_DATE DATE as (value:c8::date),
	CST_PREF_STORE INT as (value:c9::int),

    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'crm/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)')
)
WITH LOCATION = @MY_AZURE_STAGE/crm/
FILE_FORMAT = source_csv
PATTERN = '.*cust_info.*\.csv$';


--CRM: prd_info files
CREATE OR REPLACE EXTERNAL TABLE CRM_PRD_INFO_EXT(
    PRD_ID INT as (value:c1::int),
	PRD_KEY STRING as (value:c2::varchar),
	PRD_NM STRING as (value:c3::varchar),
	PRD_PRICE INT as (value:c4::int),

    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'crm/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)')
)
WITH LOCATION = @MY_AZURE_STAGE/crm/
FILE_FORMAT = source_csv
PATTERN = '.*prd_info.*\.csv$';


--ERP: cust_az12 files
CREATE OR REPLACE EXTERNAL TABLE ERP_CUST_AZ12_EXT(
    CID STRING as (value:c1::varchar),
	BDATE DATE as (value:c2::date),
	GEN STRING as (value:c3::varchar),

    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'erp/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)')
)
WITH LOCATION = @MY_AZURE_STAGE/erp/
FILE_FORMAT = source_csv
PATTERN = '.*cust_az12.*\.csv$';


--ERP: px_cat_g1v2 files
CREATE OR REPLACE EXTERNAL TABLE ERP_PX_CAT_G1V2_EXT(
    ID STRING as (value:c1::varchar),
	CAT STRING as (value:c2::varchar),
	SUBCAT STRING as (value:c3::varchar),

    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'erp/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)')
)
WITH LOCATION = @MY_AZURE_STAGE/erp/
FILE_FORMAT = source_csv
PATTERN = '.*px_cat_g1v2.*\.csv$';


--ERP: store files
CREATE OR REPLACE EXTERNAL TABLE ERP_STORES_EXT(
    STOREID INT as (value:c1::int),
	STORENAME STRING as (value:c2::varchar),
	STORELOC STRING as (value:c3::varchar),

    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'erp/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)'),
)
WITH LOCATION = @MY_AZURE_STAGE/erp/
FILE_FORMAT = source_csv
PATTERN = '.*stores.*\.csv$';


--POS: POS files
CREATE OR REPLACE EXTERNAL TABLE POS_SALES_DETAILS_EXT(
    SLS_ORD_NUM VARCHAR as (value:c1::varchar),
	SLS_PRD_KEY VARCHAR as (value:c2::varchar),
	SLS_CUST_ID VARCHAR as (value:c3::varchar),
	SLS_ORDER_DT DATE as (value:c4::date),
	SLS_SHIP_DT DATE as (value:c5::date),
	SLS_DUE_DT DATE as (value:c6::date),
	SLS_SALES INT as (value:c7::int),
	SLS_QUANTITY INT as (value:c8::int),
	SLS_PRICE INT as (value:c9::int),
	SLS_PTS_RCVD INT as (value:c10::int),
	SLS_PYMNT_CHNNL VARCHAR as (value:c11::varchar),
	SLS_STORE_ID INT as (value:c12::int),
    SRC_YEAR INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'pos/([0-9]{4})/',1,1,'e',1)),
    SRC_MONTH INT AS TO_NUMBER(REGEXP_SUBSTR(METADATA$FILENAME,'/([0-9]{2})/', 1,1,'e',1)),
    SRC_FILE VARCHAR AS METADATA$FILENAME --REGEXP_SUBSTR(METADATA$FILENAME, '([^/]+$)')
)
WITH LOCATION = @MY_AZURE_STAGE/pos/
FILE_FORMAT = source_csv
PATTERN = '.*sales_details.*\.csv$';


