{{ config(
    enabled=true,
    materialized= 'view',
    schema= 'SQUARE',
    tags= ["staging", "daily"]
    ) 
}}
 

WITH source_catalog_modifier AS (
  SELECT * FROM  {{source('OLD_SQUARE','CATALOG_MODIFIER')}}
),
source_order_line_item_modifier AS (
SELECT DISTINCT  K_POS_ORDER_LINE_ITEM_BK,K_POS_CATALOG_OBJECT_BK FROM  {{ref('V_ORDER_LINE_ITEM_MODIFIER_STG')}}
),
source_order_line_item AS (
SELECT DISTINCT K_CATALOG_OBJECT_DLHK,K_CATALOG_OBJECT_BK, K_ORDER_LINE_BK FROM  {{ref('V_ORDER_LINE_ITEM_STG')}}
),
rename as (
SELECT DISTINCT
       --MD5 KEYS
         MD5( TRIM(COALESCE(CM.ID, '00000000000000000000000000000000'))  ) AS K_MODIFIER_DLHK
         ,CLI.K_CATALOG_OBJECT_DLHK         
        --BUSINESS KEYS        
        ,CM.ID AS K_MODIFIER_BK
        ,CLI.K_CATALOG_OBJECT_BK
        ,OLIM.K_POS_CATALOG_OBJECT_BK
       -- ,OLIM.K_POS_CATALOG_OBJECT_MODIFIER_BK
        --METRICS
        ,CM.PRICE_MONEY_AMOUNT AS M_PRICE_MONEY_AMOUNT        
        --DESCRIPTION
        ,CM.PRICE_MONEY_CURRENCY AS POS_PRICE_MONEY_CURRENCY
        ,CM.NAME AS POS_MODIFIER        
        --metadata (MD)
        ,CURRENT_TIMESTAMP AS MD_LOAD_DTS        
        ,'{{invocation_id}}' AS MD_INTGR_ID
FROM
    source_order_line_item_modifier AS OLIM
    INNER JOIN source_catalog_modifier AS CM ON CM.ID = OLIM.K_POS_CATALOG_OBJECT_BK    
    INNER JOIN source_order_line_item as CLI ON CLI.K_ORDER_LINE_BK = OLIM.K_POS_ORDER_LINE_ITEM_BK
)

SELECT * FROM rename