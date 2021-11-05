{{ config (
  materialized= 'view',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}

WITH source AS (
  SELECT * FROM  {{source('OLD_SQUARE','ORDER_LINE_ITEM')}}
),

rename AS 
(
  SELECT 
--PRIMARY KEYS  
  UID AS ORDERLINE_ID,
--FOREIGN KEYS  
  ORDER_ID AS ORDERLINE_ORDER_ID,
  CATALOG_OBJECT_ID AS ORDERLINE_CATALOG_OBJECT_ID,
--OTHER FIELDS
  NAME AS ORDERLINE_NAME,
  QUANTITY AS ORDERLINE_QUANTITY,
  NOTE AS ORDERLINE_NOTE,
  VARIATION_NAME AS ORDERLINE_VARIATION_NAME,
  BASE_PRICE_AMOUNT AS ORDERLINE_BASE_PRICE_AMOUNT,
  BASE_PRICE_CURRENCY AS ORDERLINE_BASE_PRICE_CURRENCY,
  GROSS_SALES_AMOUNT AS ORDERLINE_GROSS_SALES_AMOUNT,
  GROSS_SALES_CURRENCY AS ORDERLINE_GROSS_SALES_CURRENCY,
  TOTAL_TAX_AMOUNT AS ORDERLINE_TOTAL_TAX_AMOUNT,
  TOTAL_TAX_CURRENCY AS ORDERLINE_TOTAL_TAX_CURRENCY,
  TOTAL_DISCOUNT_AMOUNT AS ORDERLINE_TOTAL_DISCOUNT_AMOUNT,
  TOTAL_DISCOUNT_CURRENCY AS ORDERLINE_TOTAL_DISCOUNT_CURRENCY,
  TOTAL_AMOUNT AS ORDERLINE_TOTAL_AMOUNT,
  TOTAL_CURRENCY AS ORDERLINE_TOTAL_CURRENCY,
  VARIATION_TOTAL_PRICE_AMOUNT AS ORDERLINE_VARIATION_TOTAL_PRICE_AMOUNT,
  VARIATION_TOTAL_PRICE_CURRENCY AS ORDERLINE_VARIATION_TOTAL_PRICE_CURRENCY,
  __ROW_MD5 AS ORDERLINE___ROW_MD5,
  __DLH_IS_DELETED AS ORDERLINE___DLH_IS_DELETED,
  __DLH_SYNC_TS AS ORDERLINE___DLH_SYNC_TS,
  __DLH_START_TS AS ORDERLINE___DLH_START_TS,
  __DLH_FINISH_TS AS ORDERLINE___DLH_FINISH_TS,
  __DLH_IS_ACTIVE AS ORDERLINE___DLH_IS_ACTIVE

FROM source
)

SELECT * FROM rename