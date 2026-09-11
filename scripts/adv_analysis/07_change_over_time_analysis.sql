USE DataWarehouse

-- Advances Analytics Project 
-- Changes Over Time Analysis

-- Analyze how a measure evolves over time and helps track trends and identify seasonality in your data 
-- exp :- Total Sales By Year, Average Cost By Month


-- Task :- Analyse Sales Performance Overtime

SELECT 
    YEAR(order_date) AS order_year,
    SUM(sales_amount) AS total_sales_amount,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) As total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date) 
ORDER BY YEAR(order_date);


-- Doing same for month by

SELECT  
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales_amount,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) As total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY MONTH(order_date) 
ORDER BY MONTH(order_date);


-- Aggregating Data by year and month as well

SELECT 
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales_amount,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) As total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY YEAR(order_date), MONTH(order_date) 
ORDER BY YEAR(order_date), MONTH(order_date);


-- Instead of YEAR() using DATETRUNC()

SELECT 
    DATETRUNC(month, order_date) AS order_year,
    SUM(sales_amount) AS total_sales_amount,
    COUNT(DISTINCT customer_key) AS total_customer,
    SUM(quantity) As total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY DATETRUNC(month, order_date) 
ORDER BY DATETRUNC(month, order_date);
