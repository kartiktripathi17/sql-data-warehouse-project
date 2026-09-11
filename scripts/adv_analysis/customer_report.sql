-- Advanced Analytics Project 
-- Build Customer Report


-- SQL Task — Customer Report

-- Create a customer report that:

-- Gathers customer information such as:
-- Names
-- Ages
-- Transaction details


-- Segments customers into:
-- VIP
-- Regular
-- New
-- Age groups


-- Calculates customer-level metrics:
-- Total orders
-- Total sales
-- Total quantity purchased
-- Total products
-- Customer lifespan (in months)


-- Calculates valuable KPIs:
-- Recency — months since the last order
-- Average order value
-- Average Monthly Spend


CREATE VIEW gold.report_customers AS

WITH base_query AS 
(

/*--------------------------------------------------------------------------------
1) Base Query: Retrieves core columns from table
--------------------------------------------------------------------------------*/

SELECT 
    f.order_number,
    f.product_key,
    f.order_date,
    f.sales_amount,
    f.quantity,
    c.customer_key,
    c.customer_number,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer c
    ON c.customer_key = f.customer_key
WHERE order_date IS NOT NULL
)


, customer_aggregation AS
(
    
/*--------------------------------------------------------------------------------
1) Customer Aggregations: Summarizes key metrics at the customer level
--------------------------------------------------------------------------------*/

SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    DATEDIFF(year, MIN(order_date), MAX(order_date)) AS lifespan 
FROM base_query
GROUP BY 
    customer_key,
    customer_number,
    customer_name,
    age
)


SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    CASE 
        WHEN age <= 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
    ELSE '50 and above'
    END AS 'age_group',

    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END customer_segment, 

    last_order_date,
    DATEDIFF(month, last_order_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,

    --Compuate Average Order Value (AOV)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_value,

    -- Compuate Average Monthly Spend (total sales / nr of month)
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS monthly_spend

FROM customer_aggregation;


SELECT
    age_group,
    COUNT(customer_number) AS total_customers,
    SUM(total_sales) AS total_sales
FROM gold.report_customers;
