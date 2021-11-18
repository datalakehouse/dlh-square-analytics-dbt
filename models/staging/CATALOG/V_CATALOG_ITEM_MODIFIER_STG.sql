{{ config (
  materialized= 'view',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}

WITH 
source AS (
SELECT * FROM  {{ref('V_ORDER_LINE_ITEM_MODIFIER_STG')}}
), renamed AS (
SELECT DISTINCT
       --MD5 KEYS
       K_POS_CATALOG_OBJECT_HASH_DLHK
        ,K_POS_CATALOG_OBJECT_DLHK AS K_POS_CATALOG_MODIFIER_DLHK
        ,K_POS_CATALOG_OBJECT_ITEM_DLHK AS K_POS_CATALOG_OBJECT_DLHK         
        --BUSINESS KEYS        
        ,K_POS_CATALOG_OBJECT_BK AS K_POS_CATALOG_MODIFIER_BK
        ,K_POS_CATALOG_OBJECT_ITEM_BK AS K_POS_CATALOG_OBJECT_BK
        ,COALESCE(K_POS_LOCATION_BK,'N/A') AS K_POS_LOCATION_BK 
        --ATTRIBUTES
        ,A_POS_PRODUCT_NAME AS A_POS_PRODUCT_NAME
        ,NULL AS A_POS_PRODUCT_SUB_NAME        
        ,COALESCE(A_POS_CATEGORY_NAME,'No Category') AS A_POS_CATEGORY_NAME 
        ,'ORDER LINE ITEM MODIFIER' AS A_POS_USAGE       
        --METRICS
        ,A_POS_CATALOG_MODIFIER_PRICE_MONEY_CURRENCY AS M_PRICE_MONEY_AMOUNT        
        --DESCRIPTION
        ,M_CATALOG_MODIFIER_PRICE_MONEY_AMOUNT AS A_POS_PRICE_MONEY_CURRENCY
        ,A_POS_MODIFIER_NAME AS A_POS_CATALOG_MODIFIER_NAME
        --metadata (MD)
        ,CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
   source
)

SELECT 
*
FROM renamed