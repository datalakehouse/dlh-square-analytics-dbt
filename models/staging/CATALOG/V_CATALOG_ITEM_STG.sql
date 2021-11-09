{{ config(
    enabled=true,
    materialized= 'view',
    schema= 'SQUARE',
    tags= ["staging", "daily"]
    ) 
}}
 

WITH source AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_ITEM')}}
),
source_variation AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_ITEM_VARIATION')}}
),
source_category AS (
  SELECT * FROM  {{ref('V_CATALOG_CATEGORY_STG')}}
),
source_order_line_item AS (
SELECT DISTINCT K_CATALOG_OBJECT_DLHK,K_CATALOG_OBJECT_BK, K_ORDER_LINE_BK,ORDERLINE_VARIATION_NAME,ORDERLINE_NAME  FROM  {{ref('V_ORDER_LINE_ITEM_STG')}}
),
rename as (


SELECT DISTINCT
       --MD5 KEYS        
        MD5( V.ID ) AS K_POS_CATALOG_OBJECT_VARIATION_DLHK        
        --BUSINESS KEYS
        ,V.ID AS K_POS_CATALOG_OBJECT_VARIATION_BK       
        ,S.ID AS K_POS_CATALOG_OBJECT_BK
        --DESCRIPTION
        ,COALESCE(S.NAME, OLI.ORDERLINE_NAME) AS A_POS_PRODUCT_NAME
        ,COALESCE(OLI.ORDERLINE_VARIATION_NAME, 'N/A') AS A_POS_PRODUCT_SUB_NAME
        ,COALESCE(CAT.POS_PRODUCT_CATEGORY, 'No Category') AS A_POS_CATEGORY_NAME
        , 'ORDER LINE ITEM' AS A_POS_USAGE
        ,S.DESCRIPTION AS A_POS_PRODUCT_DESCRIPTION
        ,S.ABBREVIATION AS A_POS_PRODUCT_ABBREVIATION
        ,S.PRODUCT_TYPE AS A_POS_PRODUCT_TYPE
        ,V.NAME AS A_POS_PRODUCT_VARIATION_NAME
        ,V.SKU AS A_POS_PRODUCT_SKU
        ,V.UPC AS A_POS_PRODUCT_UPC
        ,V.ORDINAL AS A_POS_ORDINAL_VARIATION 
        ,V.PRICING_TYPE AS A_POS_VARIATION_PRICING_TYPE
        ,V.PRICE_MONEY_CURRENCY AS A_POS_VARIATION_PRICE_MONEY_CURRENCY
        --METRIC
        ,V.PRICE_MONEY_CURRENCY AS M_POS_VARIATION_PRICE_MONEY_CURRENCY
        --metadata (MD)
        , CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        , '{{invocation_id}}' AS MD_INTGR_ID
FROM
    source S
    INNER JOIN source_variation AS V ON V.ITEM_ID = S.ID
    INNER JOIN source_order_line_item AS OLI ON V.ID = OLI.K_CATALOG_OBJECT_BK
    LEFT JOIN source_category AS CAT ON CAT.K_CATALOG_CATEGORY_BK = S.CATEGORY_ID
    
)

SELECT * FROM rename