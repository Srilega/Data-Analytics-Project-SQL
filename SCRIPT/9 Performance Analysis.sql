/*
Performance Analysis
====================
In this Analysis, we are comparing the current value to the target value
and it is used to analyse the performance of our business.
*/

/* Analyze the yearly performance of products by comparing their sales 
to both the average sales performance of the product and the previous year's sales */

WITH yearly_products_sales AS (
		SELECT 
			YEAR(f.order_date) AS order_year,
            p.product_name,
            SUM(f.sales_amount) AS current_sales
		FROM fact_sales f
        LEFT JOIN dim_products p
        ON f.product_key = p.product_key
        WHERE f.order_date IS NOT NULL
        GROUP BY YEAR(f.order_date),p.product_name
        
	)
	SELECT 
		order_year,
        product_name,
        current_sales,
        AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales,
        current_sales - AVG(current_sales) OVER(PARTITION BY product_name) AS avg_sales_diff,
        CASE 
			WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)>0 THEN 'Above Avg'
            WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name)<0 THEN 'Below Avg'
            ELSE 'Avg'
		END Avg_change,
-- Year Over Year Analysis
		LAG(current_sales) OVER(PARTITION BY product_name) AS previous_sales,
        current_sales - LAG(current_sales) OVER(PARTITION BY product_name) AS sales_diff,
        CASE
			WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name) >0 THEN 'Increase'
			WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name) <0 THEN 'Decrease'
			ELSE 'No Change'
		END sales_change
    FROM yearly_products_sales
    GROUP BY order_year, product_name;
    
            
            
            
                    
                