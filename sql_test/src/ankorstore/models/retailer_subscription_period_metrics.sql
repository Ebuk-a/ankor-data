with orders_data as (

    -- This refers to the table created from seeds/orders.csv
    select * from {{ ref('orders') }}

),

retailer_subscription_periods_data as (

    -- This refers to the table created from seeds/retailer_subscription_periods.csv
    select * from {{ ref('retailer_subscription_periods') }}

),

joined_data as (
    select
        row_number() over (order by dt_period_start) as id_period,
        o.id_retailer,
        dt_period_start,
        dt_period_end,
        sum(discount_amount) as period_discount
    from orders_data o
    inner join retailer_subscription_periods_data rsp
    on o.id_retailer = rsp.id_retailer
    and o.dt_submitted between rsp.dt_period_start and rsp.dt_period_end
    group by o.id_retailer, dt_period_start, dt_period_end
    )

select * from joined_data




