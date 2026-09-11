-- Create a Product Report that consolidates key product metrics and customer behavior.

-- The report should:

-- Include essential product information
-- Product name
-- Category
-- Subcategory
-- Cost


-- Segment products based on revenue
-- High-Performers
-- Mid-Range
-- Low-Performers


-- Calculate product-level metrics
-- Total orders
-- Total sales
-- Total quantity sold
-- Total unique customers
-- Lifespan (in months)


-- Calculate additional KPIs
-- Recency → months since the product's last sale
-- Average Order Revenue (AOR)
-- Average Monthly Revenue


CREATE VIEW gold.report_products AS

WITH base_query AS (
    
/*--------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products 
--------------------------------------------------------------------------------*/

SELECT
    f.order_number,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE order_date IS NOT NULL -- Only conider valid sales dates
),


product_aggregations AS (
    
/*--------------------------------------------------------------------------------
2) Products Aggregations: Summarizes key metrics at the product level
--------------------------------------------------------------------------------*/

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
    MAX(order_date) AS last_sale_date,
    COUNT(DISTINCT order_number) AS total_orders,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    ROUND(
        AVG(
            CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)
        ), 
        1
    ) AS avg_selling_price
FROM base_query
GROUP BY 
    product_key,
    product_name,
    category,
    subcategory,
    cost
)


/*--------------------------------------------------------------------------------
3) Final Query: Combines all product results into one output
--------------------------------------------------------------------------------*/

SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    CASE
        WHEN total_sales > 50000 THEN 'High-Performance'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    -- Average Order Revenue (AOR)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders 
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales/lifespan
    END AS avg_monthly_revenue

FROM product_aggregations;
