{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_data', 'customers_raw') }}
),renamed as (
    select
        -- Primary Key
        cst_id as customer_id,
        -- Customer Details
        cst_nm as customer_name,
        emil as email,
        ph as phone,
        addr as address,
        
        -- Timestamps
        crt_at as created_at,
        upd_at as updated_at
        
        -- Metadata can be added here if needed
    from source
)

select * from renamed