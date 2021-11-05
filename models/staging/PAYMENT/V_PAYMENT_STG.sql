{{ config (
  materialized= 'view',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}

WITH source AS (
  SELECT * FROM  {{source('OLD_SQUARE','PAYMENT')}}
),

renamed_casted AS 
(
 SELECT
        --MD5 KEYS
        MD5( ID ) AS K_POS_PAYMENT_DLHK 
        ,MD5( TRIM(COALESCE(LOCATION_ID, '00000000000000000000000000000000'))  ) AS K_POS_MERCH_LOC_DLHK
        ,MD5( TRIM(COALESCE(ORDER_ID, '00000000000000000000000000000000'))  ) AS K_POS_ORDER_DLHK
        ,MD5( TRIM(COALESCE(CUSTOMER_ID, '00000000000000000000000000000000')) ) AS K_POS_CUSTOMER_DLHK 
        ,MD5( TRIM(COALESCE(TOTAL_MONEY_CURRENCY, '00000000000000000000000000000000')) ) AS K_CURRENCY_DLHK
        ,MD5 (TRIM(COALESCE(EMPLOYEE_ID,'00000000000000000000000000000000'))) AS K_EMPLOYEE_DLHK
        ,MD5(TO_VARCHAR(CREATED_AT::date, 'YYYYMMDD')) AS K_DATE_DLHK -- need to rereference this to a RawDV DLHVID identifier that has 32 charts in the date_d dimension        
        ,TO_VARCHAR(CREATED_AT::date, 'YYYYMMDD')::int AS K_DATE_ID
        --BUSINESS KEYS
        ,ID AS K_POS_PAYMENT_BK
        ,LOCATION_ID AS K_POS_PAYMENT_LOCATION_BK
        ,ORDER_ID AS K_POS_PAYMENT_ORDER_BK
        ,CUSTOMER_ID AS K_POS_PAYMENT_CUSTOMER_BK
        ,EMPLOYEE_ID AS K_EMPLOYEE_BK
        --METRICS
        ,ROUND(NVL(AMOUNT_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_PAYMENT_MONEY_AMT
        ,ROUND(NVL(APP_FEE_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_PAYMENT_APP_FEE_AMT
        ,ROUND(NVL(REFUNDED_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_PAYMENT_REFUND_MONEY_AMT
        ,ROUND(NVL(TIP_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_PAYMENT_TIP_AMT
        ,ROUND(NVL(TOTAL_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_PAYMENT_TOTAL_AMT  --will match the Order table TOTAL_MONEY_AMOUNT metric
        --DESCRIPTION AND DATE FIELDS
        ,TOTAL_MONEY_CURRENCY AS A_POS_PAYMENT_CURRENCY
        ,RECEIPT_NUMBER AS A_POS_PAYMENT_RECEIPT_NUMBER
        ,RECEIPT_URL AS A_POS_PAYMENT_RECEIPT_URL
        ,SOURCE_TYPE AS A_POS_PAYMENT_SOURCE_TYPE
        ,STATUS AS A_POS_PAYMENT_STATUS
        ,CREATED_AT AS A_POS_PAYMENT_CREATED_DTS
        ,UPDATED_AT AS A_POS_PAYMENT_UPDATED_DTS   
        --METADATA
        , CURRENT_TIMESTAMP AS MD_LOAD_DTS
        , MD5(CONCAT(
                IFNULL(NULLIF(TRIM(CAST(ID AS VARCHAR)), ''), '^^'), '||',
                IFNULL(NULLIF(TRIM(CAST(CUSTOMER_ID AS VARCHAR)), ''), '^^') )) AS MD_HASH_COL
        , '{{invocation_id}}' AS MD_INTGR_ID
FROM source 
)

SELECT * FROM renamed_casted