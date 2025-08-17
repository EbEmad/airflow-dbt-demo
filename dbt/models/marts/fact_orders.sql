{{
  config(
    materialized='table'
  )
}}

with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

final as (
    select
        -- Fact table primary key
        oi.order_item_id,
        
        -- Foreign keys to dimension tables
        o.order_id,
        o.customer_id,
        oi.product_id,
        
        -- Date keys
        o.created_at::date as order_date,
        o.shipped_at::date as shipped_date,
        o.delivered_at::date as delivered_date,
        
        -- Measures
        oi.quantity,
        oi.unit_price,
        oi.total_price as line_total,  -- comes from stg_order_items
        o.order_total,
        o.shipping_cost,
        o.tax_amount,
        
        -- Flags
        case when o.order_status = 'delivered' then 1 else 0 end as is_delivered,
        case when o.order_status = 'cancelled' then 1 else 0 end as is_cancelled,
        
        -- Delivery metrics
        case 
            when o.shipped_at is not null and o.delivered_at is not null 
            then (o.delivered_at::date - o.shipped_at::date)
            else null 
        end as delivery_days,
        
        -- Timestamps
        o.created_at,
        o.updated_at,
        oi._loaded_at
        
    from order_items oi
    inner join orders o on oi.order_id = o.order_id
    inner join customers c on o.customer_id = c.customer_id
    inner join products p on oi.product_id = p.product_id
)

select * from final
