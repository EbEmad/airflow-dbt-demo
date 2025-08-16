{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw_data', 'products') }}
)

select * from source