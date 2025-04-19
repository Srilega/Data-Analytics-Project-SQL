-- Change over time analysis
-- This analysis is useful to analyze how a measeure evolves over time
-- Using MONTH(),YEAR() function

SELECT 
	MONTH(order_date) AS order_month,
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(quantity) as total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date),YEAR(order_date);

-- Using DATE_FORMAT() function

SELECT 
	DATE_FORMAT(order_date,'%M') AS order_month,
    DATE_FORMAT(order_date,'%Y') AS order_year,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) as total_customers,
    SUM(quantity) as total_quantity
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date,'%M'),DATE_FORMAT(order_date,'%Y');