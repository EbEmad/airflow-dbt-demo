{{
    config(
        MATERIALIZED='table'
    )
}}

with customers as (
    select * from {{ ref('stg_customers')}}
),
orders as (
    select * from {{ ref('stg_orders') }}
),
customers_orders as(
    select customer_id,
    count(*)as number_of_orders,
    sum(order_total) as total_spent,
    min(created_at) as first_order_date,
    max(created_at)as last_order_date
    from orders
    group by customer_id
),

final as(
    select 
        c.customer_id,
        c.customer_name,
        c.email,
        c.phone,
        c.address,
        c.created_at as customer_created_at,
        c.updated_at as customer_updated_at,
        co.number_of_orders,
        co.total_spent,
        co.first_order_date,
        co.last_order_date,
        case 
            when co.number_of_orders >= 10 then 'VIP'
            when co.number_of_orders >=5 then 'Regular'
            when co.number_of_orders>=1 then 'New'
            else 'Inactive'
        end as customer_segment,
        case 
            when co.total_spent>=1000 then 'High Value'
            when co.total_spent >=500 then 'Medium Value'
            when co.total_spent >=100 then 'Low Value'
            else 'No Purchase'
        end as Value_segment

        from customers c left join  customers_orders co on c.customer_id=co.customer_id
)

select * from final

