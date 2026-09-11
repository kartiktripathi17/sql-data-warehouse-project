-- Advances Analytics Project 
-- Performance Analysis :- Comparing the current value to a target value
-- It helps measure success and compare performance
-- current_sales - average_sales
-- current_year_sales - average_sale
-- current_year_sale - previous_year_sales
-- current_sales - lowest_sales


-- Task :- Analyze the yearly performance of products by comparing
-- each product's sales to both its average sales performance and the previous year's sales.


WITH year_product_sales AS
(
    SELECT 
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE YEAR(f.order_date) IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)

SELECT 
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER(PARTITION By product_name) AS avg_sales,
    (current_sales - AVG(current_sales) OVER(PARTITION By product_name)) AS diff_avg,

    CASE 
        WHEN (current_sales - AVG(current_sales) OVER(PARTITION By product_name)) > 0 
            THEN 'Above Avg'
        WHEN (current_sales - AVG(current_sales) OVER(PARTITION By product_name)) < 0 
            THEN 'Below Avg'
        ElSE 'Avg'
    END avg_change,

    LAG(current_sales) OVER(
        PARTITION By product_name 
        ORDER BY order_year
    ) py_sales,

    current_sales - LAG(current_sales) OVER(
        PARTITION By product_name 
        ORDER BY order_year
    ) AS diff_py,

    CASE 
        WHEN (current_sales - LAG(current_sales) OVER(
            PARTITION By product_name 
            ORDER BY order_year
        )) > 0 
            THEN 'Increase'

        WHEN (current_sales - LAG(current_sales) OVER(
            PARTITION By product_name 
            ORDER BY order_year
        )) < 0 
            THEN 'Decrease'

        ElSE 'No Change'
    END py_change

FROM year_product_sales
ORDER BY product_name, order_year;


-- NOTE :- current_sales - NULL = NULL
