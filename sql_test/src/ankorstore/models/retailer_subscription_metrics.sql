with retailer_subscription_period_metrics as (

    -- This references the model retailer_subscription_period_metrics
    select * from {{ ref('retailer_subscription_period_metrics') }}

),



retailer_subscription_metrics as (
    select
        id_retailer,
        SUM(period_discount) AS total_subscription_discount,
        AVG(period_discount) AS avg_period_subscription_discount,
        MAX(period_discount) AS last_period_subscription_discount,
        MAX(dt_period_start) AS dt_last_period_start
    from retailer_subscription_period_metrics
    group by id_retailer
    )

select * from retailer_subscription_metrics




