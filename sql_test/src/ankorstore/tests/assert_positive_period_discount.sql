/*
    Test to assert that the period_discout column is not negative for any row
*/
with retailer_subscription_period_metrics as (
    select * from {{ ref('retailer_subscription_period_metrics') }}
)

select 
    id_retailer,
    period_discount
from retailer_subscription_period_metrics
where period_discount < 0