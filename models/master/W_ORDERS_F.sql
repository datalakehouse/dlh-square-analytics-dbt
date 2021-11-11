{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}

WITH source_item_allocated as (
  select 
        MAX(OLI.M_ORDER_LINE_BASE_PRICE_AMT)/COUNT(1) AS M_POS_ITEM_BASE_PRICE_AMT         
        ,K_POS_ORDER_LINE_BK
        FROM 
        {{ref('V_ORDER_LINE_ITEM_STG')}} OLI
        LEFT JOIN {{ref('V_ORDER_LINE_ITEM_MODIFIER_STG')}} OLIM ON OLIM.K_POS_ORDER_LINE_ITEM_BK = OLI.K_POS_ORDER_LINE_BK
        GROUP BY K_POS_ORDER_LINE_BK
),
source_order_allocated as (
  select MAX(O.M_NET_TIP_MONEY_AMT)/COUNT(1) AS M_NET_TIP_MONEY_AMT
        ,MAX(O.M_TOTAL_SERVICE_CHARGE_AMT)/COUNT(1) AS M_TOTAL_SERVICE_CHARGE_AMT        
        ,O.K_POS_ORDER_DLHK  
        FROM 

        {{ref('V_ORDER_HEADER_STG')}} O
        LEFT JOIN {{ref('V_ORDER_LINE_ITEM_STG')}} OLI ON OLI.K_POS_ORDER_DLHK = O.K_POS_ORDER_DLHK
        LEFT JOIN {{ref('V_ORDER_LINE_ITEM_MODIFIER_STG')}} OLIM ON OLIM.K_POS_ORDER_LINE_ITEM_BK = OLI.K_POS_ORDER_LINE_BK
        GROUP BY O.K_POS_ORDER_DLHK
),
final as (
SELECT
  O.K_POS_ORDER_DLHK
  ,O.K_POS_LOCATION_DLHK
  ,O.K_POS_REFERENCE_DLHK
  ,O.K_POS_CUSTOMER_DLHK  
  ,O.K_POS_ORDER_BK
  ,O.K_POS_LOCATION_BK
  ,O.K_POS_CUSTOMER_BK
  ,O.K_POS_REFERENCE_BK
  ,O.A_ORDER_CREATED_DTS
  ,O.A_ORDER_UPDATED_DTS
  ,O.A_ORDER_CLOSED_DTS  
  ,O.A_ORDER_STATE
  ,O.A_ORDER_SOURCE      
  
  ,OLI.K_POS_ORDER_LINE_DLHK  
  ,OLI.K_POS_CATALOG_OBJECT_DLHK
  ,OLI.K_CURRENCY_DLHK
  ,OLI.K_POS_ORDER_LINE_BK  
  ,COALESCE(OLIM.K_POS_CATALOG_OBJECT_BK,OLI.K_POS_CATALOG_OBJECT_BK) AS K_POS_CATALOG_OBJECT_BK
  ,OLI.A_POS_ORDER_LINE_NAME
  ,OLI.M_POS_ORDER_LINE_QUANTITY
  ,OLI.A_POS_ORDER_LINE_NOTE  
  ,OLI.A_POS_ORDER_LINE_VARIATION_NAME
  ,COALESCE(SIA.M_POS_ITEM_BASE_PRICE_AMT,0) + COALESCE(OLIM.M_BASE_PRICE_AMT,OLI.M_ORDER_LINE_BASE_PRICE_AMT) AS M_ALLOCATED_BASE_PRICE_AMT 


  ,ROUND(DIV0((OLI.M_ORDER_LINE_GROSS_SALES_AMT * M_ALLOCATED_BASE_PRICE_AMT), OLI.M_ORDER_LINE_GROSS_SALES_AMT),4)::decimal(15,4) AS M_ALLOCATED_ORDER_LINE_GROSS_SALES_AMT  
  ,ROUND(DIV0((OLI.M_ORDER_LINE_TOTAL_TAX_AMT * M_ALLOCATED_BASE_PRICE_AMT), OLI.M_ORDER_LINE_GROSS_SALES_AMT),4)::decimal(15,4) AS M_ALLOCATED_ORDER_LINE_TOTAL_TAX_AMT  
  ,ROUND(DIV0((OLI.M_ORDER_LINE_TOTAL_DISCOUNT_AMT * M_ALLOCATED_BASE_PRICE_AMT), OLI.M_ORDER_LINE_GROSS_SALES_AMT),4)::decimal(15,4) AS M_ALLOCATED_ORDER_LINE_TOTAL_DISCOUNT_AMT  
  ,ROUND(DIV0((OLI.M_POS_ITEM_NET_AMT * M_ALLOCATED_BASE_PRICE_AMT), OLI.M_ORDER_LINE_GROSS_SALES_AMT),4)::decimal(15,4) AS M_ALLOCATED_POS_ITEM_NET_AMT  
  ,M_ALLOCATED_POS_ITEM_NET_AMT + M_ALLOCATED_ORDER_LINE_TOTAL_TAX_AMT AS M_ALLOCATED_POS_TOTAL_AMT
  
  
  ,ROUND(NVL(SOA.M_NET_TIP_MONEY_AMT, 000), 4)::decimal(15,4)  AS M_ALLOCATED_NET_TIP_MONEY_AMT
  --,ROUND(DIV0((O.M_NET_TIP_MONEY_AMT * M_ALLOCATED_BASE_PRICE_AMT),O.M_NET_TOTAL_AMT),4)::decimal(15,4) as A
  ,ROUND(NVL(SOA.M_TOTAL_SERVICE_CHARGE_AMT, 000), 4)::decimal(15,4)  AS M_ALLOCATED_TOTAL_SERVICE_CHARGE_AMT  
  --,ROUND(DIV0((O.M_TOTAL_SERVICE_CHARGE_AMT * M_ALLOCATED_BASE_PRICE_AMT),O.M_NET_TOTAL_AMT),2)::decimal(15,2) as B
  

  ,NVL(OLIM.M_BASE_PRICE_AMT,000)::decimal(15,4) AS M_POS_ITEM_MOD_PRICE_AMT
  ,NVL(OLIM.M_TOTAL_PRICE_AMOUNT,000)::decimal(15,4) AS M_POS_ITEM_MOD_TOTAL_AMT
  
  
  ,O.MD_LOAD_DTS
  ,O.MD_INTGR_ID
FROM
  {{ref('V_ORDER_HEADER_STG')}} AS O 
  LEFT JOIN {{ref('V_ORDER_LINE_ITEM_STG')}} OLI ON OLI.K_POS_ORDER_DLHK = O.K_POS_ORDER_DLHK
  LEFT JOIN {{ref('V_ORDER_LINE_ITEM_MODIFIER_STG')}} OLIM ON OLIM.K_POS_ORDER_LINE_ITEM_BK = OLI.K_POS_ORDER_LINE_BK
  LEFT JOIN source_item_allocated SIA ON SIA.K_POS_ORDER_LINE_BK = OLIM.K_POS_ORDER_LINE_ITEM_BK
  LEFT JOIN source_order_allocated SOA ON SOA.K_POS_ORDER_DLHK = O.K_POS_ORDER_DLHK  
)

SELECT * FROM final