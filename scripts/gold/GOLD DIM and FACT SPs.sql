USE DATABASE SALES;
USE SCHEMA GOLD;
USE ROLE SYSADMIN;

--==--
GRANT USAGE ON PROCEDURE SALES.GOLD.SP_LOAD_DIM_CUSTOMER() TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE SALES.GOLD.SP_LOAD_DIM_PRODUCT() TO ROLE SYSADMIN;
GRANT USAGE ON PROCEDURE SALES.GOLD.SP_LOAD_DIM_STORE() TO ROLE SYSADMIN;

GRANT SELECT ON VIEW SALES.GOLD.VW_NEW_CUSTOMER_SRC TO ROLE SYSADMIN;
GRANT SELECT ON VIEW SALES.GOLD.VW_NEW_PRODUCT_SRC TO ROLE SYSADMIN;

--==--
CALL GOLD.SP_LOAD_DIM_STORE();
CALL GOLD.SP_LOAD_DIM_CUSTOMER();
CALL GOLD.SP_LOAD_DIM_PRODUCT();
--==--


--DIM STORE
CREATE OR REPLACE PROCEDURE GOLD.SP_LOAD_DIM_STORE()
    RETURNS STRING
    LANGUAGE SQL
    AS 
    BEGIN 
        -- PERFORM SCD 1
        MERGE INTO SALES.GOLD.DIM_STORE AS TGT 
        USING SALES.SILVER.ERP_STORES AS SRC 
        ON TGT.STORE_ID = SRC.STOREID
        
        WHEN MATCHED
        AND (
            TGT.STORE_NAME <> SRC.STORENAME
	        OR TGT.STORE_LOCATION <> SRC.STORELOC
        ) 
        THEN UPDATE
        
        SET
            TGT.STORE_NAME = SRC.STORENAME,
            TGT.STORE_LOCATION = SRC.STORELOC

        WHEN NOT MATCHED THEN
        INSERT
            (
                STORE_ID,
            	STORE_NAME,
            	STORE_LOCATION,
            	DWH_CREATE_DATE
            )
        VALUES
            (
                SRC.STOREID,
                SRC.STORENAME,
                SRC.STORELOC,
                DWH_CREATE_DATE
            );
            
        RETURN 'SCD 1 Successful for DIM_STORE';
END;


--DIM CUSTOMER
CREATE OR REPLACE PROCEDURE GOLD.SP_LOAD_DIM_CUSTOMER()
    RETURNS STRING
    LANGUAGE SQL
    AS 
    BEGIN 
        MERGE INTO SALES.GOLD.DIM_CUSTOMER AS TGT 
        USING SALES.GOLD.VW_NEW_CUSTOMER_SRC AS SRC 
        ON TGT.CUSTOMER_ID = SRC.CST_ID
        AND TGT.DWH_STATUS = SRC.DWH_STATUS
        WHERE SRC.CST_ID != '0' --Skip bad records
        
        --Update records to make them expired
        WHEN MATCHED
        AND (
            TGT.CUSTOMER_NUMBER <> SRC.CST_KEY
            OR TGT.FIRST_NAME <> SRC.CST_FIRSTNAME
            OR TGT.LAST_NAME <> SRC.CST_LASTNAME
            OR TGT.BIRTH_DATE <> SRC.BDATE
            OR TGT.MARITAL_STATUS <> SRC.CST_MARITAL_STATUS
            OR TGT.GENDER <> SRC.CST_GNDR_derived
            OR TGT.CREATE_DATE <> SRC.CST_CREATE_DATE
            OR TGT.LOYALTY_JOIN_DATE <> SRC.CST_LOYALTY_JOIN_DATE
            OR TGT.STORE_KEY <> SRC.STORE_KEY
        ) 
        THEN UPDATE
        
        SET
            TGT.DWH_STATUS = 'Expired',
            TGT.DWH_END_DATE = GETDATE() -- VARIABLE TO LOAD DATE

        --Insert new records
        WHEN NOT MATCHED THEN
        INSERT
            (
                CUSTOMER_ID,
                CUSTOMER_NUMBER,
                FIRST_NAME,
                LAST_NAME,
                BIRTH_DATE,
                MARITAL_STATUS,
                GENDER,
                CREATE_DATE,
                LOYALTY_JOIN_DATE,
                STORE_KEY,
                DWH_STATUS,
                DWH_START_DATE,
                DWH_END_DATE,
                DWH_CREATE_DATE
            )
        VALUES
            (
                SRC.CST_ID,
                SRC.CST_KEY,
                SRC.CST_FIRSTNAME,
                SRC.CST_LASTNAME,
                SRC.BDATE,
                SRC.CST_MARITAL_STATUS,
                SRC.CST_GNDR_derived,
                SRC.CST_CREATE_DATE,
                SRC.CST_LOYALTY_JOIN_DATE,
                SRC.STORE_KEY,
                SRC.DWH_STATUS,
                SRC.DWH_START_DATE,
                SRC.DWH_END_DATE,
                SRC.DWH_CREATE_DATE
            );

        --Insert records that have new start date and end date
        INSERT INTO 
            SALES.GOLD.DIM_CUSTOMER (
                CUSTOMER_ID,
                CUSTOMER_NUMBER,
                FIRST_NAME,
                LAST_NAME,
                BIRTH_DATE,
                MARITAL_STATUS,
                GENDER,
                CREATE_DATE,
                LOYALTY_JOIN_DATE,
                STORE_KEY,
                DWH_STATUS,
                DWH_START_DATE,
                DWH_END_DATE,
                DWH_CREATE_DATE
            )
        SELECT
            SRC.*
        FROM
            SALES.GOLD.VW_NEW_CUSTOMER_SRC AS SRC
            LEFT JOIN SALES.GOLD.DIM_CUSTOMER AS TGT 
            ON TGT.CUSTOMER_ID = SRC.CST_ID
            AND TGT.DWH_STATUS = SRC.DWH_STATUS
        WHERE
            TGT.CUSTOMER_NUMBER IS NULL;
            
        RETURN 'Inserted Current records';
END;

--==--


USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE GOLD.SP_LOAD_DIM_PRODUCT()
    RETURNS STRING
    LANGUAGE SQL
    AS 
    BEGIN 
        MERGE INTO SALES.GOLD.DIM_PRODUCT AS TGT 
        USING SALES.GOLD.VW_NEW_PRODUCT_SRC AS SRC 
        ON TGT.PRODUCT_ID = SRC.PRD_ID
        AND TGT.DWH_STATUS = SRC.DWH_STATUS
        
        --Update records to make them expired
        WHEN MATCHED
        AND (
	           TGT.PRODUCT_ID <> SRC.PRD_ID
	           OR TGT.PRODUCT_NUMBER <> SRC.PRD_KEY
               OR TGT.PRODUCT_NAME <> SRC.PRD_NM
               OR TGT.PRODUCT_CATEGORY <> SRC.CAT
               OR TGT.PRODUCT_SUBCATEGORY <> SRC.SUBCAT
               OR TGT.PRICE <> SRC.PRD_PRICE
            ) 
        THEN UPDATE
        
        SET
            TGT.DWH_STATUS = 'Expired',
            TGT.DWH_END_DATE = GETDATE() -- VARIABLE TO LOAD DATE

        --Insert new records
        WHEN NOT MATCHED THEN
        INSERT
            (
                PRODUCT_ID,
                PRODUCT_NUMBER,
                PRODUCT_NAME,
                PRODUCT_CATEGORY,
                PRODUCT_SUBCATEGORY,
                PRICE,
                DWH_STATUS,
                DWH_START_DATE,
                DWH_END_DATE,
                DWH_CREATE_DATE
            )
        VALUES
            (
                SRC.PRD_ID,
                SRC.PRD_KEY,
                SRC.PRD_NM,
                SRC.CAT,
                SRC.SUBCAT,
                SRC.PRD_PRICE,
                SRC.DWH_STATUS,
                SRC.DWH_START_DATE,
                SRC.DWH_END_DATE,
                SRC.DWH_CREATE_DATE
            );

        --Insert records that have new start date and end date
        INSERT INTO 
            SALES.GOLD.DIM_PRODUCT (
                PRODUCT_ID,
                PRODUCT_NUMBER,
                PRODUCT_NAME,
                PRODUCT_CATEGORY,
                PRODUCT_SUBCATEGORY,
                PRICE,
                DWH_STATUS,
                DWH_START_DATE,
                DWH_END_DATE,
                DWH_CREATE_DATE
            )
        SELECT
            SRC.*
        FROM
            SALES.GOLD.VW_NEW_PRODUCT_SRC AS SRC
            LEFT JOIN SALES.GOLD.DIM_PRODUCT AS TGT 
            ON TGT.PRODUCT_ID = SRC.PRD_ID
            AND TGT.DWH_STATUS = SRC.DWH_STATUS
        WHERE
            TGT.PRODUCT_KEY IS NULL;
            
        RETURN 'Inserted Current records';
END;

--==--

USE ROLE SYSADMIN;
CREATE OR REPLACE PROCEDURE SALES.GOLD.SP_LOAD_FACT_SALES()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS 'BEGIN
INSERT INTO SALES.GOLD.FACT_SALES
    (
    	ORDER_DATE_KEY,
    	CUSTOMER_KEY,
    	PRODUCT_KEY,
    	STORE_KEY,
    	SHIP_DATE_KEY,
    	DUE_DATE_KEY,
    	ORDER_NUMBER,
    	SALES,
    	QUANTITY,
    	PRICE,
    	POINTS_RECEIVED,
    	PAYMENT_CHANNEL,
    	DWH_CREATE_DATE
    )
SELECT 
    DDT.DATE_KEY AS ORDER_DATE_KEY,
    DCS.CUSTOMER_KEY AS CUSTOMER_KEY,
    DPR.PRODUCT_KEY AS PRODUCT_KEY,
    DST.STORE_KEY AS STORE_KEY,
    DDS.DATE_KEY AS SHIP_DATE_KEY,
	DDD.DATE_KEY AS DUE_DATE_KEY,
    SLS.SLS_ORD_NUM AS ORDER_NUMBER,
	SLS.SLS_SALES AS SALES,
	SLS.SLS_QUANTITY AS QUANTITY,
	SLS.SLS_PRICE AS PRICE,
	SLS.SLS_PTS_RCVD AS POINTS_RECEIVED,
	SLS.SLS_PYMNT_CHNNL AS PAYMENT_CHANNEL,
	SLS.DWH_CREATE_DATE AS DWH_CREATE_DATE
FROM 
    SALES.SILVER.CRM_SALES_DETAILS SLS
    LEFT JOIN GOLD.DIM_STORE DST
    ON SLS.SLS_STORE_ID = DST.STORE_ID
    LEFT JOIN GOLD.DIM_CUSTOMER DCS
    ON SLS.SLS_CUST_ID = DCS.CUSTOMER_ID
    LEFT JOIN GOLD.DIM_PRODUCT DPR
    ON SLS.SLS_PRD_KEY = DPR.PRODUCT_NUMBER
    LEFT JOIN GOLD.DIM_DATE DDT
    ON SLS.SLS_ORDER_DT = DDT.DATE
    LEFT JOIN GOLD.DIM_DATE DDS
    ON SLS.SLS_SHIP_DT = DDS.DATE
    LEFT JOIN GOLD.DIM_DATE DDD
    ON SLS.SLS_DUE_DT = DDD.DATE
WHERE
    DCS.DWH_STATUS = ''Current''
    AND DPR.DWH_STATUS = ''Current'';
    
     RETURN ''Inserted Fact table records'';
 END';


----
