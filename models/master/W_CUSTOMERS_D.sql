{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}


SELECT
  *
FROM
  {{ref('V_CUSTOMER_STG')}} AS C