{{ config(
    enabled=true
    ) 
}}
 

WITH source_catalog_item AS (
  SELECT * FROM  {{ref('V_CATALOG_ITEM_STG')}}
),
source_catalog_item_modifier_list_info AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_ITEM_MODIFIER_LIST_INFO')}}
),
source_catalog_modifier_list AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_MODIFIER_LIST')}}
),
source_catalog_modifier_override AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_MODIFIER_OVERRIDE')}}
),
source_catalog_modifier AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_MODIFIER')}}
),

rename as (


SELECT
       --MD5 KEYS
        C.K_CATALOG_ITEM_DLHK
        ,MD5( TRIM(COALESCE(CMO.MODIFIER_LIST_ID, '00000000000000000000000000000000'))  ) AS K_MODIFIER_LIST_DLHK
        ,MD5( TRIM(COALESCE(CM.ID, '00000000000000000000000000000000'))  ) AS K_MODIFIER_DLHK
        --BUSINESS KEYS
        ,C.K_CATALOG_ITEM_BK
        ,CMO.MODIFIER_LIST_ID AS K_MODIFIER_LIST_BK
        ,CM.ID AS K_MODIFIER_BK
        --METRICS
        ,CM.PRICE_MONEY_AMOUNT AS M_PRICE_MONEY_AMOUNT        
        --DESCRIPTION
        ,CM.PRICE_MONEY_CURRENCY AS POS_PRICE_MONEY_CURRENCY
        ,CM.NAME AS POS_MODIFIER        
        --metadata (MD)
        , CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        , '{{invocation_id}}' AS MD_INTGR_ID
FROM
    source_catalog_item AS C
    INNER JOIN source_catalog_item_modifier_list_info AS CIM ON CIM.ITEM_ID = C.K_CATALOG_ITEM_BK
    INNER JOIN source_catalog_modifier_list AS CML ON CML.ID = CIM.MODIFIER_LIST_ID
    INNER JOIN source_catalog_modifier_override AS CMO ON CMO.MODIFIER_LIST_ID = CML.ID AND CMO.ITEM_ID = C.K_CATALOG_ITEM_BK
    INNER JOIN source_catalog_modifier CM ON CM.ID = CMO.MODIFIER_ID
)

SELECT * FROM rename