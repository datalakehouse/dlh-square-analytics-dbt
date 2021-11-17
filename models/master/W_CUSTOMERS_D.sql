{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"],
  enabled=true
)
}}


SELECT
  *
FROM
  {{ref('V_CUSTOMER_STG')}} AS C