/*
===============================================================================
Quality Checks
===============================================================================

Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.

===============================================================================
*/


USE DataWarehouse;
GO


/*=============================================================================
  Checking 'gold.dim_customer'
=============================================================================*/

-- Check for Uniqueness of Customer Key in gold.dim_customer
-- Expectation: No Results

SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;


/*=============================================================================
  Checking 'gold.dim_products'
=============================================================================*/

-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No Results

SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


/*=============================================================================
  Checking 'gold.fact_sales'
=============================================================================*/

-- Check for Referential Integrity between Fact and Customer Dimension
-- Expectation: No Results

SELECT 
    f.customer_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;


/*=============================================================================
  Check for Referential Integrity between Fact and Product Dimension
=============================================================================*/

-- Expectation: No Results

SELECT 
    f.product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
WHERE p.product_key IS NULL;


/*=============================================================================
  Check for Foreign Key Integrity
=============================================================================*/

-- Check whether all customer and product keys in fact_sales
-- have corresponding records in their dimension tables.
-- Expectation: No Results

SELECT 
    f.order_number,
    f.customer_key,
    f.product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customer AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE c.customer_key IS NULL
   OR p.product_key IS NULL;


/*=============================================================================
  Gold Layer Quality Checks Completed
=============================================================================*/
