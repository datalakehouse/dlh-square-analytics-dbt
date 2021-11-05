{{ config(
    enabled=true,
    materialized= 'view',
    schema= 'SQUARE',
    tags= ["staging", "daily"]
    ) 
}}
 

WITH source AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_CATEGORY')}}
),

rename as (


SELECT
       --MD5 KEYS
        MD5( ID ) AS K_CATALOG_CATEGORY_DLHK        
        --BUSINESS KEYS
        ,ID AS K_CATALOG_CATEGORY_BK        
        --DESCRIPTION
        ,NAME AS POS_PRODUCT_CATEGORY        
        --metadata (MD)
        , CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        , '{{invocation_id}}' AS MD_INTGR_ID
FROM
    source
)

SELECT * FROM rename