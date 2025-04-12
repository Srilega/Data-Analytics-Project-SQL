/*
===============================================================================
Ranking Analysis
===============================================================================
Purpose:
    - To rank items (e.g., products, customers) based on performance or other metrics.
    - To identify top performers or laggards.

SQL Functions Used:
    - Window Ranking Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), TOP
    - Clauses: GROUP BY, ORDER BY
===============================================================================
*/

-- Which 5 products Generating the Highest Revenue?
WITH CTE AS(
		SELECT 
			p.product_id,
            p.product_name,
			SUM(f.sales_amount) as revenue,
            RANK() OVER(ORDER BY SUM(f.sales_amount) DESC) AS RNK
		FROM fact_sales f
        JOIN dim_products p
        ON f.product_key = p.product_key
        GROUP BY p.product_id,p.product_name
			)
SELECT * FROM CTE
WHERE RNK<=5;


-- What are the 5 worst-performing products in terms of sales?
WITH CTE AS(
		SELECT 
			p.product_id,
            p.product_name,
			SUM(f.sales_amount) as revenue,
            RANK() OVER(ORDER BY SUM(f.sales_amount)ASC) AS RNK
		FROM fact_sales f
        JOIN dim_products p
        ON f.product_key = p.product_key
        GROUP BY p.product_id,p.product_name
			)
SELECT * FROM CTE
WHERE RNK<=5;


-- Find the top 10 customers who have generated the highest revenue
SELECT * FROM
(SELECT 
		c.customer_id,
		SUM(f.sales_amount) AS total_revenue,
		ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rwn
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_id) AS new1
WHERE rwn<=10;

-- The 3 customers with the fewest orders placed

SELECT *
FROM
(SELECT 
	c.customer_id,
    SUM(quantity),
	ROW_NUMBER() OVER(ORDER BY SUM(f.quantity) ASC)AS rwn1
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_id) AS new2
WHERE rwn1<=3;
