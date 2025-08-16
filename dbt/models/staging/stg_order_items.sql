{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_data', 'order_items') }}
)

select * from source