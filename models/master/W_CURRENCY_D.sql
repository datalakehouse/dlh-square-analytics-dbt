{{ config (
  materialized= 'table',
  source=var('target_schema'),
  tags= ["staging", "daily"],
  transient=false
)
}}


SELECT
  *
FROM
  {{ref('V_CURRENCY_STG')}} AS C