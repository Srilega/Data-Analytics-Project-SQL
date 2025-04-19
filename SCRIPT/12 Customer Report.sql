/*
Customer Reports
================

Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
*/
-- Retrieve Core columns from the table

WITH base_query AS(
SELECT 
	c.customer_key,
    c.customer_number,
    CONCAT(c.first_name,' ',c.last_name) AS customer_name,
    TIMESTAMPDIFF(year,c.birthdate,curdate()) AS age,
    f.order_number,
    f.order_date,
    f.product_key,
    f.sales_amount,
    f.quantity,
    f.price
FROM fact_sales f
LEFT JOIN dim_customers c
ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL),
-- aggregated columns

customer_aggregation AS(
SELECT 
	customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(quantity) AS total_quantity_purchased,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) AS life_span
FROM base_query
GROUP BY customer_key,
		 customer_number,
		 customer_name,
         age
)
SELECT 
	customer_number,
    customer_key,
    customer_name,
    age,
    total_orders,
    total_quantity_purchased,
    total_products,
    total_sales,
    life_span,
    CASE WHEN age < 20 THEN 'Under 20'
		 WHEN age BETWEEN 20 AND 30 THEN '20-30'
		 WHEN age BETWEEN 30 AND 50 THEN '30-50'
         WHEN age > 50 THEN 'Above 50'
	END AS age_categories,
    CASE WHEN life_span >= 12 AND total_sales > 5000 THEN 'VIP'
		 WHEN life_span >= 12 AND total_sales <= 5000 THEN 'Regular'
		 ELSE 'New'
	END AS customer_segments,
    TIMESTAMPDIFF(month,last_order_date,curdate()) AS recency,
-- Average Order values
	(total_sales/total_orders) AS avg_order_value,
-- Average Monthly spend
	(total_sales/life_span) AS avg_monthly_spend
FROM customer_aggregation;
    