{{ config (
  materialized= 'view',
  schema=var('target_schema', 'SQUARE'),
  tags= ["staging", "daily"]
)
}}

WITH source AS (
  SELECT * FROM  {{source(var('source_schema', 'DEMO_SQUARE_ALT13'),'ORDER_LINE_ITEM')}}
),
source_item_variation AS (
  SELECT * FROM  {{source(var('source_schema', 'DEMO_SQUARE_ALT13'),'CATALOG_ITEM_VARIATION')}}
),
source_order AS (
SELECT DISTINCT K_POS_ORDER_DLHK,K_POS_LOCATION_BK  FROM  {{ref('V_SQR_ORDER_HEADER_STG')}}
),
source_category AS (
  SELECT * FROM  {{ref('V_SQR_CATALOG_CATEGORY_STG')}}
),
source_item AS (
  SELECT * FROM  {{source(var('source_schema', 'DEMO_SQUARE_ALT13'),'CATALOG_ITEM')}}
),
rename AS 
(
SELECT
 MD5 (S.UID) AS K_POS_ORDER_LINE_DLHK
  ,MD5 (TRIM(S.ORDER_ID)) AS K_POS_ORDER_DLHK
  ,MD5( TRIM(COALESCE(S.CATALOG_OBJECT_ID, '00000000000000000000000000000000'))  ) AS K_POS_CATALOG_OBJECT_DLHK
  ,MD5( TRIM(COALESCE(SIT.ID,  '00000000000000000000000000000000'))) AS K_POS_CATALOG_OBJECT_ITEM_DLHK
  ,MD5( TRIM(COALESCE(TOTAL_CURRENCY, '00000000000000000000000000000000')) ) AS K_CURRENCY_DLHK
--BUSINESS KEYS
  ,S.UID AS K_POS_ORDER_LINE_BK
  ,S.ORDER_ID AS K_POS_ORDER_BK  
  ,S.CATALOG_OBJECT_ID AS K_POS_CATALOG_OBJECT_BK
  ,SIT.ID AS K_POS_CATALOG_OBJECT_ITEM_BK
  ,O.K_POS_LOCATION_BK
--OTHER FIELDS
  ,COALESCE(SIT.NAME,SI.NAME,S.NAME,'None') AS A_POS_PRODUCT_NAME
  ,SI.NAME AS A_POS_PRODUCT_VARIATION_NAME
  ,COALESCE(CAT.A_POS_PRODUCT_CATEGORY, 'No Category') AS A_POS_CATEGORY_NAME
  ,S.NAME AS A_POS_ORDER_LINE_NAME
  ,S.QUANTITY AS M_POS_ORDER_LINE_QUANTITY
  ,S.NOTE AS A_POS_ORDER_LINE_NOTE  
  ,S.VARIATION_NAME AS A_POS_ORDER_LINE_VARIATION_NAME
  ,SI.PRICE_MONEY_CURRENCY AS A_POS_VARIATION_PRICE_MONEY_CURRENCY
--METRIC
  ,ROUND(NVL(SI.PRICE_MONEY_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_POS_ITEM_VARIATION_PRICE_MONEY_AMOUNT
  ,ROUND(NVL(S.BASE_PRICE_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_ORDER_LINE_BASE_PRICE_AMT
  ,ROUND(NVL(S.GROSS_SALES_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_ORDER_LINE_GROSS_SALES_AMT
  ,ROUND(NVL(S.TOTAL_TAX_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_ORDER_LINE_TOTAL_TAX_AMT
  ,ROUND(NVL(S.TOTAL_DISCOUNT_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_ORDER_LINE_TOTAL_DISCOUNT_AMT
  ,ROUND(NVL(S.TOTAL_AMOUNT, 000)/100, 2)::decimal(15,2) AS M_ORDER_LINE_TOTAL_AMT
  ,ROUND(NVL(S.GROSS_SALES_AMOUNT, 000)/100, 2) - ROUND(NVL(TOTAL_DISCOUNT_AMOUNT, 000)/100, 2) AS M_POS_ITEM_NET_AMT
FROM source S
LEFT JOIN source_order O ON O.K_POS_ORDER_DLHK = MD5(TRIM(S.ORDER_ID))
LEFT JOIN source_item_variation AS SI ON SI.ID = S.CATALOG_OBJECT_ID
LEFT JOIN source_item AS SIT ON SIT.ID = SI.ITEM_ID
LEFT JOIN source_category AS CAT ON CAT.K_POS_CATALOG_CATEGORY_BK = SIT.CATEGORY_ID
)

SELECT 
 MD5(CONCAT(K_POS_CATALOG_OBJECT_DLHK,K_POS_LOCATION_BK,A_POS_PRODUCT_NAME,COALESCE(A_POS_ORDER_LINE_VARIATION_NAME,'NA'),K_POS_CATALOG_OBJECT_ITEM_DLHK)) AS K_POS_CATALOG_OBJECT_HASH_DLHK,
* FROM rename