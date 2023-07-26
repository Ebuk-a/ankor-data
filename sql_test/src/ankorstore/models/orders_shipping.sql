with orders_data as (

    -- This refers to the table created from seeds/orders.csv
    select * from {{ ref('orders') }}

),

brands_data as (

    -- This refers to the table created from seeds/retailers.csv
    select * from {{ ref('brands') }}

),


orders_shipping as (
    select
        orders.id_order,
        orders.dt_submitted,
        brands.nb_brand_shipping_days,
        (
            select count(distinct dt_day)
            from dev.public_holidays public_holidays
            where public_holidays.country = brands.country
            and public_holidays.dt_day between orders.dt_submitted and
            (orders.dt_submitted + (interval '1' day * brands.nb_brand_shipping_days))
        ) as nb_holidays,
        (
            orders.dt_submitted + (interval '1' day *  brands.nb_brand_shipping_days)
        ) +
            interval '1' day * (
                                    select count(distinct dt_day)
                                    from dev.public_holidays public_holidays
                                    where public_holidays.country = brands.country
                                    and public_holidays.dt_day between orders.dt_submitted and
                                    (orders.dt_submitted + (interval '1' day * brands.nb_brand_shipping_days))
                                ) 
        as dt_estimated_delivered
    from dev.orders orders
    inner join dev.brands brands
    on orders.id_brand = brands.id_brand
    )

select * from orders_shipping
