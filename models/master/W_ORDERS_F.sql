{{ config (
  materialized= 'table',
  schema= 'DATAFORM',
  tags= ["staging", "daily"]
)
}}

SELECT
  *
FROM
  {{ref('W_ORDERS_STG')}} AS O 
  LEFT JOIN {{ref('W_ORDER_LINE_ITEM_STG')}} OLI ON OLI.ORDERLINE_ORDER_ID = O.ORDER_ID
  LEFT JOIN {{ref('W_ORDER_DISCOUNTS_STG')}} OD ON OD.ORDERDISCOUNT_ORDER_ID = O.ORDER_ID