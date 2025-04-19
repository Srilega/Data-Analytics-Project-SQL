/*
Part to whole Analysis
======================
This Analysis is used to analyse how an individual part is performing compared to the overall.
[measure]/total[measure]*100 by [dimensions]
*/

-- Which categories contribute the most to overall sales?
WITH cte AS(SELECT
	p.category,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category)
SELECT 
	category,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
	ROUND((CAST(total_sales AS FLOAT)/(SUM(total_sales) OVER())*100),2) AS proportion
FROM cte
ORDER BY proportion DESC;