/*
============================================
Create Bronze Layer Tables
============================================
Script Purpose:
    This script creates the bronze layer tables for both CRM and ERP data sources.

Notes:
    Naming convention: {SOURCE_SYSTEM}_{DATASET_NAME}
        e.g. cust_info dataset from CRM data source is CRM_CUST_INFO
        
    Data structure:
        In Snowflake, it's okay to not add the length of the data type. Snowflake will read the column based on the max length of the data stored.

    

*/
USE DATABASE SALES;



--------------------------------------------
-- Create bronze tables for CRM datasets
--------------------------------------------

-- Create bronze table for cust_info dataset
CREATE OR REPLACE TABLE BRONZE.CRM_CUST_INFO (
    CST_ID INT,
    CST_KEY VARCHAR,
    CST_FIRSTNAME VARCHAR,
    CST_LASTNAME VARCHAR,
    CST_MARITAL_STATUS VARCHAR,
    CST_GNDR VARCHAR,
    CST_CREATE_DATE DATE, 
    CST_LOYALTY_JOIN_DATE DATE,
    CST_PREF_STORE INT
);

-- Create bronze table for prd_info dataset
CREATE OR REPLACE TABLE BRONZE.CRM_PRD_INFO (
    PRD_ID INT,
    PRD_KEY VARCHAR,
    PRD_NM VARCHAR,
    PRD_PRICE DECIMAL(20,2)
);


-- Create bronze table for sales_details dataset
CREATE OR REPLACE TABLE BRONZE.CRM_SALES_DETAILS (
    SLS_ORD_NUM VARCHAR,
    SLS_PRD_KEY VARCHAR,
    SLS_CUST_ID VARCHAR,
    SLS_ORDER_DT DATE,
    SLS_SHIP_DT DATE,
    SLS_DUE_DT DATE,
    SLS_SALES DECIMAL(20,2),
    SLS_QUANTITY INT,
    SLS_PRICE DECIMAL(20,2),
    SLS_PTS_RCVD DECIMAL (20,2),
    SLS_PYMNT_CHNNL VARCHAR,
    SLS_STORE_ID INT
);


--------------------------------------------
-- Create bronze tables for ERP datasets
--------------------------------------------

-- Create bronze table for cust_az12 dataset
CREATE OR REPLACE TABLE BRONZE.ERP_CUST_AZ12 (
	CID VARCHAR,
	BDATE DATE,
	GEN VARCHAR
);

-- Create bronze table for px_cat_g1v2 dataset
CREATE OR REPLACE TABLE BRONZE.ERP_PX_CAT_G1V2 (
    ID VARCHAR,
    CAT VARCHAR,
    SUBCAT VARCHAR
);

-- Create bronze table for stores dataset
CREATE OR REPLACE TABLE BRONZE.ERP_stores (
    STOREID INT,
    STORENAME VARCHAR,
    STORELOC VARCHAR
);

