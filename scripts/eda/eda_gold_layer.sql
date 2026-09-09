/*
===============================================================================
Exploratory Data Analysis (EDA) - Gold Layer
===============================================================================
Purpose:
    This script performs exploratory data analysis on the Gold Layer
    of the Data Warehouse.

Analysis includes:
    - Database Exploration
    - Dimension Exploration
    - Date Exploration
    - Key Business Metrics
    - Magnitude Analysis
    - Ranking Analysis
===============================================================================
*/

USE DataWarehouse;


-- =============================================================================
-- Exploratory Data Analysis
-- Database Exploration
-- =============================================================================


-- Explore distinct categories

SELECT DISTINCT 
    category
FROM gold.dim_products;


-- Explore distinct sales amounts

SELECT DISTINCT 
    sales_amount
FROM gold.fact_sales;


-- Explore distinct birthdates

SELECT DISTINCT 
    birthdate
FROM gold.dim_customer;


-- Explore distinct customer IDs

SELECT DISTINCT 
    customer_id
FROM gold.dim_customer;


-- Explore all objects in the Database

SELECT * 
FROM INFORMATION_SCHEMA.TABLES;


-- Explore all columns in the Database

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customer';


-- =============================================================================
-- Exploratory Data Analysis
-- Dimension Exploration
-- =============================================================================


-- Explore all countries our customers come from

SELECT DISTINCT 
    country 
FROM gold.dim_customer;


-- Explore all categories, subcategories and products

SELECT DISTINCT 
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY 1, 2, 3;


-- =============================================================================
-- Exploratory Data Analysis
-- Date Exploration
-- Identify the earliest and latest dates (boundaries)
-- =============================================================================


-- Task : - Find the date of the first and last order

SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;


-- Task : - Find the youngest and oldest customer

SELECT 
    MIN(birthdate) AS oldest_birthdate,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
    DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customer;


-- =============================================================================
-- Exploratory Data Analysis
-- Measure Exploration
-- Calculate the key metrics of the business (Big Numbers)
-- =============================================================================


-- Task : - Find the Total Sales

SELECT 
    SUM(sales_amount) AS total_sales_amount
FROM gold.fact_sales;


-- Task : - Find how many items are sold

SELECT 
    SUM(quantity) AS total_quantity
FROM gold.fact_sales;


-- Task : - Find the average selling price

SELECT 
    AVG(sls_price) AS average_selling_price
FROM gold.fact_sales;


-- Task : - Find the Total number of Orders

SELECT 
    COUNT(order_number) AS total_orders
FROM gold.fact_sales;


-- Find total number of unique orders

SELECT 
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;


-- Explore all sales data

SELECT * 
FROM gold.fact_sales;


-- Task : - Find the Total number of products

SELECT 
    COUNT(product_key) AS total_products
FROM gold.dim_products;


-- Find total number of unique products

SELECT 
    COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;


-- Task : - Find the total number of customers

SELECT 
    COUNT(customer_key) AS total_customers
FROM gold.dim_customer;


-- Task : - Find the total number of customers that has placed an order

SELECT 
    COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales;


-- Task : - Generate report that shows all key metrics of the business

SELECT 
    'Total Sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Quantity',
    SUM(quantity)
FROM gold.fact_sales

UNION ALL

SELECT 
    'Average Price',
    AVG(sls_price)
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Nr. Orders',
    COUNT(DISTINCT order_number)
FROM gold.fact_sales

UNION ALL

SELECT 
    'Total Nr. Products',
    COUNT(product_name)
FROM gold.dim_products

UNION ALL

SELECT 
    'Total Nr. Customers',
    COUNT(customer_key)
FROM gold.dim_customer;


-- =============================================================================
-- Exploratory Data Analysis
-- Magnitude Analysis
-- Compare the measure values by categories
-- =============================================================================

-- It helps us to understand the importance of different categories

-- Examples:
-- Total Sales by Country
-- Total Quantity by Category
-- Average Price by Product
-- Total Orders by Customer


-- Task : - Find total customers by countries

SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customer
GROUP BY country
ORDER BY total_customers DESC;


-- Task : - Find total customers by gender

SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customer
GROUP BY gender
ORDER BY total_customers DESC;


-- Task : - Find total products by category

SELECT 
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;


-- Task : - What is the average costs in each category?

SELECT 
    category,
    AVG(cost) AS avg_costs
FROM gold.dim_products
GROUP BY category
ORDER BY avg_costs DESC;


-- Task : - What is the total revenue generated for each category?

SELECT  
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;


-- Task : - Find total revenue generated by each customer

SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- Task : - What is the distribution of sold items across countries?

SELECT 
    c.country,
    SUM(f.quantity) AS total_sales_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sales_items DESC;


-- =============================================================================
-- Exploratory Data Analysis
-- Ranking Analysis
-- Order the values of dimensions by measure
-- =============================================================================

-- It identifies Top N performers | Bottom N performers


-- Task : - Which 5 products generate the highest revenue?

SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- Doing same task using rank function

SELECT *
FROM
(
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (
            ORDER BY SUM(f.sales_amount) DESC
        ) AS rank_products
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS t
WHERE rank_products <= 5;


-- Task : - What are the 5 worst-performing products in terms of sales?

SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue;


-- Doing same task using rank function

SELECT *
FROM
(
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (
            ORDER BY SUM(f.sales_amount) ASC
        ) AS rank_products
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS t
WHERE rank_products <= 5;


-- =============================================================================
-- Customer Ranking Analysis
-- =============================================================================


-- Task : - Find the Top-10 customers who have generated the highest revenue

SELECT TOP 10
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC;


-- Task : - Find 3 customers with the fewest orders placed

SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
GROUP BY 
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders;
