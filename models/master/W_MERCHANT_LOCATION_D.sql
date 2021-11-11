{{ config (
  materialized= 'table',
  schema= 'SQUARE',
  tags= ["staging", "daily"]
)
}}


SELECT
  *
FROM
  {{ref('V_MERCHANT_LOCATION_STG')}} AS M