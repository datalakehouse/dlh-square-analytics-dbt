{% snapshot w_customers_snapshot_d %}

{{
    config(
      target_database='DEVELOPER_SANDBOX',
      target_schema='DBT_SQUARE',
      unique_key='K_POS_CUSTOMER_CUSTOMER_DLHK',
      strategy='timestamp',
      updated_at='A_POS_CUSTOMER_UPDATED_AT_DTS',
    )
}}

select * from {{ ref('W_CUSTOMERS_D') }}

{% endsnapshot %}