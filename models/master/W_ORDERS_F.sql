{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}

SELECT
  *
FROM
  {{ref('V_ORDERS_STG')}} AS O 
  LEFT JOIN {{ref('V_ORDER_LINE_ITEM_STG')}} OLI ON OLI.ORDERLINE_ORDER_ID = O.ORDER_ID