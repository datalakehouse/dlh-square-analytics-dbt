{{ config (
  materialized= 'table',
  schema= 'DATAFORM',
  tags= ["staging", "daily"]
)
}}


SELECT
  *
FROM
  {{ref('W_CUSTOMER_STG')}} AS C