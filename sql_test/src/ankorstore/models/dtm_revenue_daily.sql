with dtm_revenue_daily_data as (

    -- This references the model stg_dtm_revenue_daily
    select * from {{ ref('stg_dtm_revenue_daily') }}

),


filtered_cols_data as (
    select
        id,
        dt_submitted as dt_day,
        retailer_country_group,
        order_type,
        revenue
    from dtm_revenue_daily_data
)

select * from filtered_cols_data




