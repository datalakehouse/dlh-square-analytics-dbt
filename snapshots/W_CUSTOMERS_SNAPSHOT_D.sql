{% snapshot w_customers_snapshot_d %}

{{
    config(
      target_schema=var('target_schema'),
      unique_key='K_POS_CUSTOMER_DLHK',
      strategy='timestamp',
      updated_at='A_POS_UPDATED_AT_DTS',
    )
}}

select * from {{ ref('W_SQR_CUSTOMERS_D') }}

{% endsnapshot %}
