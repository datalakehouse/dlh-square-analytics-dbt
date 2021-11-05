{{ config(
    enabled=true
    ) 
}}
 

WITH source AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_ITEM')}}
),

rename as (


SELECT
       --MD5 KEYS
        MD5( ID ) AS K_CATALOG_ITEM_DLHK
        ,MD5( TRIM(COALESCE(CATEGORY_ID, '00000000000000000000000000000000'))  ) AS K_CATEGORY_DLHK
        --BUSINESS KEYS
        ,ID AS K_CATALOG_ITEM_BK
        ,CATEGORY_ID AS K_CATEGORY_BK
        --DESCRIPTION
        ,NAME AS POS_PRODUCT_NAME
        ,DESCRIPTION AS POS_PRODUCT_DESCRIPTION
        ,ABBREVIATION AS POS_PRODUCT_ABBREVIATION
        ,PRODUCT_TYPE AS POS_PRODUCT_TYPE
        --metadata (MD)
        , CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        , '{{invocation_id}}' AS MD_INTGR_ID
FROM
    source
)

SELECT * FROM rename