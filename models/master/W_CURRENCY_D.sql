{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}


SELECT
  *
FROM
  {{ref('V_CURRENCY_STG')}} AS C