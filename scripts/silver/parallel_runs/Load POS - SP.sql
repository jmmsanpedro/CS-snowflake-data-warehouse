USE ROLE ACCOUNTADMIN;
USE DATABASE SALES;


-- Load SILVER.POS_SALES_DETAILS 1 of 1 silver POS tables
CREATE OR REPLACE PROCEDURE SILVER.SP_LOAD_POS_SALES_DETAILS()
RETURNS STRING
LANGUAGE SQL
AS
BEGIN
    LET V_YEAR INT := (select year FROM METADATADB.PUBLIC.ETL_CONFIG_TABLE WHERE STATUS = 1);
    LET V_MONTH INT:= (select month FROM METADATADB.PUBLIC.ETL_CONFIG_TABLE WHERE STATUS = 1);
    LET SQL_CMD STRING :=
    '
    INSERT INTO
        SALES.SILVER.POS_SALES_DETAILS
    WITH SALES_DETAILS AS (
    SELECT
        SD.SLS_ORD_NUM,
        CASE
            WHEN LEN(SLS_PRD_KEY) != 8 THEN RIGHT(SLS_PRD_KEY, 8)
            ELSE SLS_PRD_KEY
        END AS SLS_PRD_KEY_correct,
        IFNULL(CI.CST_ID, ''0'') AS SLS_CUST_ID,
        SD.SLS_ORDER_DT,
        SD.SLS_SHIP_DT,
        SD.SLS_DUE_DT,
        CASE
            WHEN PRD.PRD_PRICE = SD.SLS_PRICE THEN SD.SLS_SALES
            WHEN PRD.PRD_PRICE != SD.SLS_PRICE THEN PRD.PRD_PRICE * SLS_QUANTITY
        END AS SLS_SALES_correct,
        SD.SLS_QUANTITY,
        SD.SLS_PRICE,
        ROUND(SLS_SALES_correct * 0.10,2) AS SLS_PTS_RCVD_correct,
        CASE
            WHEN SD.SLS_PYMNT_CHNNL = 0 THEN ''Card''
            WHEN SD.SLS_PYMNT_CHNNL = 1 THEN ''Cash''
            ELSE ''N/A''
        END AS SLS_PYMNT_CHNNL_correct,
        SD.SLS_STORE_ID,
        GETDATE() AS DWH_CREATE_DATE
    FROM
        (
            SELECT
                *,
                ROW_NUMBER() OVER (
                    PARTITION BY SLS_ORD_NUM
                    ORDER BY
                        SLS_ORDER_DT DESC
                ) AS ROWNUM
            FROM
                SALES.BRONZE.POS_SALES_DETAILS_EXT
            WHERE
                SRC_YEAR = ' || V_YEAR || ' AND
                SRC_MONTH = ' || V_MONTH || '
        ) AS SD
        LEFT JOIN SILVER.CRM_PRD_INFO PRD ON SLS_PRD_KEY_correct = PRD.PRD_KEY
        LEFT JOIN SILVER.CRM_CUST_INFO CI ON SD.SLS_CUST_ID = CI.CST_ID
    WHERE
        ROWNUM = 1
    )
        SELECT 
            SLS_ORD_NUM,
            IFNULL(SLS_PRD_KEY_correct,''0'') AS SLS_PRD_KEY_correct,
            SLS_CUST_ID,
            SLS_ORDER_DT,
            SLS_SHIP_DT,
            SLS_DUE_DT,
            SLS_SALES_correct,
            SLS_QUANTITY,
            SLS_PRICE,
            SLS_PTS_RCVD_correct,
            SLS_PYMNT_CHNNL_correct,
            SLS_STORE_ID,
            DWH_CREATE_DATE
        FROM 
            SALES_DETAILS';

    EXECUTE IMMEDIATE SQL_CMD;

    RETURN 'Successfully loaded SALES.SILVER.POS_SALES_DETAILS';
END;
