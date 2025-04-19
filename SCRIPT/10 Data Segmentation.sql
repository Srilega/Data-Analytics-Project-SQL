/* 
Data Segmantation Analysis
==========================
This is used to group data into meaningful categories for targeted insights.
For customer segmentation, product categorization, or regional analysis.
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/
WITH product_segments AS(
	SELECT 
		product_key,
        product_name,
        cost,
        CASE
			WHEN cost <100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
		END AS cost_range
	FROM dim_products
)
SELECT 
	cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*Group customers into three segments based on their spending behavior:
	- VIP: Customers with at least 12 months of history and spending more than €5,000.
	- Regular: Customers with at least 12 months of history but spending €5,000 or less.
	- New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
With customer_segments AS(
	SELECT 
		c.customer_number,
        CONCAT(c.first_name,c.last_name) AS customer_name,
		TIMESTAMPDIFF(MONTH,Min(f.order_date),MAX(f.order_date))AS life_span,
		SUM(sales_amount) AS total_spending
    FROM fact_sales f
    LEFT JOIN dim_customers c
    ON f.customer_key = c.customer_key
	GROUP BY c.customer_number,CONCAT(c.first_name,c.last_name)
)
SELECT 	
	customer_type,
    COUNT(customer_number) AS total_cutomers
FROM (SELECT 
		customer_number,
		CASE 
		WHEN life_span>=12 AND total_spending >5000 THEN 'VIP'
		WHEN life_span>=12 AND total_spending <=5000 THEN 'Regular'
		ELSE 'New'
	END AS customer_type
    FROM customer_segments
    ) AS d
GROUP BY customer_type;
