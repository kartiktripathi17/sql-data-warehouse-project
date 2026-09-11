USE DataWarehouse


-- Exploratory Data Analysis

-- Dimension Exploration


-- Explore all countries our customers come from.

SELECT DISTINCT 
    country 
FROM gold.dim_customer


-- Explore All Categories "The Major Divisions"

SELECT DISTINCT 
    category, 
    subcategory, 
    product_name 
FROM gold.dim_products
ORDER BY 1, 2, 3
