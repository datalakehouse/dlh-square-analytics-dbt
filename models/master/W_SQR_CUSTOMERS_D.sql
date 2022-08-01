{{ config (
  materialized= 'table',
  schema=var('target_schema', 'SQUARE'),
  tags= ["staging", "daily"],
  transient=false
)
}}


SELECT
  *
FROM
  {{ref('V_SQR_CUSTOMER_STG')}} AS C