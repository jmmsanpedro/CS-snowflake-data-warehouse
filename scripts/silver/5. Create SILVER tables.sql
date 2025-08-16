/*
============================================
Create Silver Layer Tables
============================================
Script Purpose:
    This script creates the silver layer tables for both CRM and ERP data sources.

*/
USE DATABASE SALES;



--------------------------------------------
-- Create silver tables for CRM datasets
--------------------------------------------

-- Create silver table for cust_info dataset
CREATE OR REPLACE TABLE SILVER.CRM_CUST_INFO (
    CST_ID INT,
    CST_KEY VARCHAR,
    CST_FIRSTNAME VARCHAR,
    CST_LASTNAME VARCHAR,
    CST_MARITAL_STATUS VARCHAR,
    CST_GNDR VARCHAR,
    CST_CREATE_DATE DATE, 
    CST_LOYALTY_JOIN_DATE DATE,
    CST_PREF_STORE INT,
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);

-- Create silver table for prd_info dataset
CREATE OR REPLACE TABLE SILVER.CRM_PRD_INFO (
    PRD_ID INT,
    PRD_KEY VARCHAR,
    PRD_NM VARCHAR,
    PRD_PRICE DECIMAL(20,2),
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);


-- Create silver table for sales_details dataset
CREATE OR REPLACE TABLE SILVER.CRM_SALES_DETAILS (
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
    SLS_STORE_ID INT,
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);


--------------------------------------------
-- Create silver tables for ERP datasets
--------------------------------------------

-- Create silver table for cust_az12 dataset
CREATE OR REPLACE TABLE SILVER.ERP_CUST_AZ12 (
	CID VARCHAR,
	BDATE DATE,
	GEN VARCHAR,
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);

-- Create silver table for px_cat_g1v2 dataset
CREATE OR REPLACE TABLE SILVER.ERP_PX_CAT_G1V2 (
    ID VARCHAR,
    CAT VARCHAR,
    SUBCAT VARCHAR,
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);

-- Create silver table for stores dataset
CREATE OR REPLACE TABLE SILVER.ERP_stores (
    STOREID INT,
    STORENAME VARCHAR,
    STORELOC VARCHAR,
    DWH_CREATE_DATE DATETIME DEFAULT GETDATE()
);
