/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
DROP VIEW IF EXISTS products_report;
CREATE VIEW products_report AS

WITH base_query AS (
	SELECT
		p.product_key,
        p.product_number,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost,
        f.order_number,
        f.customer_key,
        f.order_date,
        f.quantity,
        f.sales_amount
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL
),
product_aggregation AS(
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
	COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS revenue,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT customer_key) AS total_customers,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date))  AS life_span,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
		 product_name,
		 category,
		 subcategory,
         cost
)
SELECT
    product_name,
    category,
    subcategory,
    product_key,
    cost,
    total_orders,
    total_quantity_sold,
    revenue,
	CASE 
		WHEN revenue > 50000 THEN 'High Performers'
        WHEN revenue  <=10000 THEN 'Mid Range'
        ELSE 'Low performers'
	END AS product_segments,
	TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
    (revenue/total_orders) AS average_order_value,
    (revenue/life_span) AS avg_monthly_spend
FROM product_aggregation;
    