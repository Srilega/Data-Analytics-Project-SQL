-- Cummulative Analysis
-- Here, we are calculating the running total or the moving average for the key metrics
-- It is useful to analyse our business whether our business is running or declining

SELECT 
		order_year,
        total_sales,
        avg_price,
        ROUND(SUM(total_sales) OVER(ORDER BY order_year),2) AS running_sales_total,
        ROUND(AVG(avg_price) OVER(ORDER BY order_year),2) AS running_average_price
FROM
(SELECT 
		YEAR(order_date) AS order_year,
        SUM(sales_amount) AS total_sales,
        ROUND(AVG(price),2) AS avg_price
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date))n;