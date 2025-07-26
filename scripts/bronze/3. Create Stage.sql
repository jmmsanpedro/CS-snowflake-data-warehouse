USE DATABASE SALES;
USE SCHEMA BRONZE;

--1. Create a file format
CREATE OR ALTER FILE FORMAT source_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' --To load data with commas
    SKIP_HEADER = 1;

--2. Create a stage with SAS credentials
CREATE OR REPLACE STAGE SALES.BRONZE.my_azure_stage
    URL='azure://snowflakedwblobstorage.blob.core.windows.net/csvdata/'
    CREDENTIALS=(AZURE_SAS_TOKEN='sv=2024-11-04&ss=bfqt&srt=co&sp=rltfx&se=2026-07-22T09:35:07Z&st=2025-07-22T01:20:07Z&spr=https&sig=9aYY%2BfM5BwGo2h4XuEgSmg9HYVowCrgc6yNqKyGqACI%3D')
    FILE_FORMAT = source_csv;

--3. Load from Stage to Bronze tables
    --CRM
    COPY INTO SALES.BRONZE.CRM_CUST_INFO
        FROM @my_azure_stage/crm/2023/01/01/cust_info.csv;

    COPY INTO SALES.BRONZE.CRM_PRD_INFO
        FROM @my_azure_stage/crm/2023/01/01/prd_info.csv;

    COPY INTO SALES.BRONZE.CRM_SALES_DETAILS
        FROM @my_azure_stage/crm/2023/01/01/sales_details.csv;

    --ERP
    COPY INTO SALES.BRONZE.ERP_CUST_AZ12
        FROM @my_azure_stage/erp/2023/01/01/cust_az12.csv;

    COPY INTO SALES.BRONZE.ERP_PX_CAT_G1V2
        FROM @my_azure_stage/erp/2023/01/01/px_cat_g1v2.csv;

    COPY INTO SALES.BRONZE.ERP_STORES
        FROM @my_azure_stage/erp/2023/01/01/stores.csv;

