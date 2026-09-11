-- Advances Analytics Project 
-- Part-to-Whole Analysis :- Analyze how an individual part is performing compared to the overall, 
-- allowing us to understand which category has the greatest impact on the business

-- exp (Measure/ Total Measure) * 100 
-- (Sales / Total Sales) * 100 By Category 
-- (Quantity / Total Quantity) * 100 By Country


-- Task :- Which categories contribute the most to overall sales? 

USE DataWarehouse

WITH category_sales AS (
    SELECT 
        category,
        SUM(sales_amount) AS total_sales 
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY category
)

SELECT 
    category,
    total_sales,
    SUM(total_sales) OVER() overall_sales,
    CONCAT(
        ROUND(
            (CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100,
            2
        ),
        '%'
    ) AS percentage_of_total
FROM category_sales;
