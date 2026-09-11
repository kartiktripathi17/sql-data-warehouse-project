USE DataWarehouse


-- Exploratory Data Analysis

-- Database Exploration


SELECT DISTINCT 
    category
FROM gold.dim_products


SELECT DISTINCT 
    sales_amount
FROM gold.fact_sales


SELECT DISTINCT 
    birthdate
FROM gold.dim_customer


SELECT DISTINCT 
    customer_id
FROM gold.dim_customer


-- Explore all objects in the Database

SELECT * 
FROM INFORMATION_SCHEMA.TABLES


-- Explore all columns in the Database

SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customer'
