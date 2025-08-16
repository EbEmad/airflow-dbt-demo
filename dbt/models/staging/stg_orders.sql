{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_data', 'orders_raw') }}
),

renamed as (
    select
        -- Primary Key
        o_id as order_id,
        
        -- Foreign Keys
        cust as customer_id,
        prod as product_id,
        
        -- Timestamps
        crt as created_at,
        upd as updated_at,
        
        -- Order Details
        status as order_status,
        total as order_total,
        addr as shipping_address,
        
        -- Metadata
        load_ts as _loaded_at,
        src_file as _source_file
    from source
)

select * from renamed
