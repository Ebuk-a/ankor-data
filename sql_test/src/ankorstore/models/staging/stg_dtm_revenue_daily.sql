with orders_data as (

    -- This refers to the table created from seeds/orders.csv
    select * from {{ ref('orders') }}

),

retailers_data as (

    -- This refers to the table created from seeds/retailers.csv
    select * from {{ ref('retailers') }}

),

joined_data as (
    select
    row_number() over (order by dt_submitted) as id,
    o.dt_submitted,
    r.country_group as retailer_country_group,
    o.id_retailer,
    o.id_brand,
    sum(o.order_amount) as revenue,
    case
        when o.dt_submitted = MIN(o.dt_submitted) over (partition by o.id_retailer) then 'new'
        when o.id_brand IN (
        select id_brand
        from orders_data
        where id_retailer = o.id_retailer
        and dt_submitted < o.dt_submitted
        ) then 'repeat reorder'
        else 'repeat discovery'
    end as order_type
    from orders_data o
    inner join retailers_data r
    on o.id_retailer = r.id_retailer
    group by o.dt_submitted, retailer_country_group, o.id_retailer, o.id_brand
)

select * from joined_data




