# Context

- The goal of this project is to test your SQL modeling skills by (i) writing queries and (ii) answering quality questions about your code.
- The code that you will write can go directly into the `/src` folder. You have to write at least one `.sql` file per model. But you are allowed to write as many queries, intermediate files, and use as many plugins and frameworks as you see fit.
- All the data needed for the modeling is available `/datalake` folder, representing the datalake. Each table is represented by a couple of files: one `.csv` file containing the data, and one `.yml` containing the schema description.

# Evaluation criterias

- The code should produce the expected output, be easy to read, and follow SQL best practices. NB: SQl is the main evaluation topic, you won’t be disadvantaged if you only wrote abstract SQL in `.sql` files without running or building the data, but having a data pipeline running is a plus (ex: sqlite).
- It's ok if you don't complete all exercices. One exercice completed with coding material delivered is better than two exercices barely started.
- The answers to quality questions are relevant.
- You can write the possible improvements that you would add to your code if you had an unlimited amount of time.
    - Added Test to assert that the period_discout column is not negative for any row.
    - More granular tests can be added to ensure data quality.

# Exercise 1

For analytics purpose, we want to create a model named `revenue_daily`. This model will contain the company revenue per day, retailer country group and order type for analytics purposes.

1. Write SQL query(ies) to create `revenue_daily`. The expected output schema is indicated below in the “Resources” section
2. Write a test query ensuring that the `id` column from your output is unique and not *null*
3. The analysts will query `revenue_daily` from our visualisation tool and display the revenue over different time period (day, week, month, etc) in their charts. In order for the charts to load faster, what would you recommend on the `revenue_daily` model materialisation?
    - Table materialization will be fastest as it creates the physical table on the database, rather than using view which is always computed using the underlying source tables (data and retailer) everytime it is queried or visualization is loaded.

**Resources**

- `dtm_revenue_daily` schema:
    - `id`: unique key of the table
    - `dt_day`: date of the day
    - `retailer_country_group`: country group of the retailer (cf `/datalake/retailers`)
    - `order_type`: order type as described below
    - `revenue`: revenue generated for the given day, retailer country and order type
- For each order, the order type indicates if it’s a new or repeat order from the retailer and can have one of the following values:
    - `new`: first order submitted by the retailer and all orders submitted on the same date (first order day)
    - `repeat reorder`: orders submitted after the first order day of the retailer, to a brand to which the retailer ordered at least once
    - `repeat discovery`: orders submitted after the first order day of the retailer, to a brand to which the retailer never ordered

# Exercise 2

Using the tables `/datalake/retailer_subscription_periods`and `/datalake/orders`, we want to create a model `retailer_subscription_metrics` containing, for each brand, the total discounts, the average discounts per period and the last period discounts.

1. Write SQL query(ies) to create `retailer_subscription_period_metrics`.
2. Using output from question 1, write SQL query(ies) to create `retailer_subscription_metrics`.
3. Is there several ways to compute `retailer_subscription_metrics`? Did you choose the most efficient?

**Resources**

- `retailer_subscription_period_metrics` schema:
    - `id_period`: unique key of the table, identifier of the subscription_period
    - `id_retailer`: identifier of the retailer
    - `dt_period_start`: date of the subscription period start
    - `dt_period_end`: date of the subscription period end
    - `period_discount`: sum of discount amount applied to the orders submitted by the retailer between `dt_period_start` and `dt_period_end` (use `discount_amount` field from `datalake/orders`)
- `retailer_subscription_metrics` schema:
    - `id_retailer`: unique key of the table, identifier of the retailer
    - `total_subscription_discount`: discount amount applied to the orders submitted by the retailer over all its subscription periods
    - `avg_period_subscription_discount`: average discount amount per subscription period
    - `last_period_subscription_discount`: discount amount of the last subscription period of the retailer
    - `dt_last_period_start`: date of the latest subscription period start

# Exercise 3

Using the tables `datalake/public_holidays` and `datalake/orders`, we want to create a new model `orders_shipping` focusing on shipping metrics. 
1. Write SQL query(ies) to create `orders_shipping`
2. How would you suggest to improve the metric `dt_estimated_delivered` ? 
    - Model an ML on historical delivery times by brands and distance, factoring in seasonal changes, traffic and shipping delays.

**Resources**

`orders_shipping` schema: 

- `id_order`: unique key of the table, identifier of the order
- `dt_submitted`: Date of the order submission by the retailer
- `nb_brand_shipping_days`: shipping time of the brand selling the order (cf `datalake/brands`)
- `dt_estimated_delivered`: estimated date of the delivering of the order to the retailer’s location, taking into account the brand shipping time and the bank holidays. The formula is:
    
    $$
    dt\_estimated\_delivered = dt\_submitted + nb\_brand\_shipping\_days + nb\_holidays
    $$
    
    With `nb_holidays` being the number of weekend & public holiday days occurring during the shipping date range. To simplify, we only take into account bank holidays in the brand country. Example: order 1 is shipped on tuesday 13/06/2023 by brand A with brand shipping time of 5 days, and the 20/06/2023 is a bank holiday in the brand country. Then:
    
    *dt_estimated_delivered =  13/06/2023*
    
    *+ 5 (brand shipping time)*
    
    *+ 2 (weekend of 17th & 18th)*
    
    *+ 1 (public holiday of the 20th)*
    
    *dt_estimated_delivered =  21/06/2023*


# Additional Optimizations
**Tests**
- To assert non-negative period_discout column on retailer_subscription_period_metrics table
- To assert unique and not-null id column on dtm_revenue_daily table
- To assert accepted-values ['new', 'repeat reorder', 'repeat discovery'] for order_type column on dtm_revenue_daily table
- To assert unique and not-null id_period column on retailer_subscription_period_metrics table
- To assert unique and not-null id_retailer column on retailer_subscription_metrics table
- To assert unique and not-null id_order column on orders_shipping table

**Optimizations**
- Exercise_1. The analysts will query `revenue_daily` from our visualisation tool and display the revenue over different time period (day, week, month, etc) in their charts. In order for the charts to load faster, what would you recommend on the `revenue_daily` model materialisation?
   - Table materialization will be fastest as it creates the physical table on the database, rather than using view which is always computed using the underlying source tables (data and retailer) everytime it is queried or visualization is loaded.

- Exercise_3: How would you suggest to improve the metric `dt_estimated_delivered` ? 
    - Model an ML on historical delivery times by brands and realtive distances, factoring in seasonal changes, traffic and shipping delays.
