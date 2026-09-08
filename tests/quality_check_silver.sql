/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs various quality checks on the Silver Layer tables.

    The checks include:
    - Primary key validation
    - Duplicate detection
    - Null value checks
    - Unwanted spaces
    - Data standardization
    - Invalid dates
    - Invalid relationships
    - Business rule validation

Expectation:
    Most queries should return NO RESULTS if the Silver Layer is clean.
===============================================================================
*/


-- =============================================================================
-- CRM: silver.crm_cust_info
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.crm_cust_info';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cst_id,
    COUNT(*) AS record_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in First Name
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Last Name
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


-- -----------------------------------------------------------------------------
-- Check for Data Standardization and Consistency
-- Expectation: Only standardized values
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info;


-- -----------------------------------------------------------------------------
-- Check for NULL values in important columns
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL
   OR cst_key IS NULL;


-- =============================================================================
-- CRM: silver.crm_prd_info
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.crm_prd_info';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    prd_id,
    COUNT(*) AS record_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Product Name
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


-- -----------------------------------------------------------------------------
-- Check for NULLs or Negative Numbers in Product Cost
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;


-- -----------------------------------------------------------------------------
-- Data Standardization and Consistency
-- Expectation: Only standardized values
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


-- -----------------------------------------------------------------------------
-- Check for Invalid Date Orders
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- -----------------------------------------------------------------------------
-- Check for overlapping product date ranges
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    prd_key,
    prd_start_dt,
    prd_end_dt,
    LEAD(prd_start_dt) OVER (
        PARTITION BY prd_key
        ORDER BY prd_start_dt
    ) AS next_prd_start_dt
FROM silver.crm_prd_info
WHERE prd_end_dt >= LEAD(prd_start_dt) OVER (
    PARTITION BY prd_key
    ORDER BY prd_start_dt
);


-- =============================================================================
-- CRM: silver.crm_sales_details
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.crm_sales_details';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs in important columns
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL
   OR sls_prd_key IS NULL
   OR sls_cust_id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Invalid Order Dates
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_order_dt > '2050-01-01'
   OR sls_order_dt < '1990-01-01';


-- -----------------------------------------------------------------------------
-- Check for Invalid Ship Dates
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR sls_ship_dt > '2050-01-01'
   OR sls_ship_dt < '1990-01-01';


-- -----------------------------------------------------------------------------
-- Check for Invalid Due Dates
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL
   OR sls_due_dt > '2050-01-01'
   OR sls_due_dt < '1990-01-01';


-- -----------------------------------------------------------------------------
-- Check for Invalid Date Orders
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_due_dt
   OR sls_order_dt > sls_ship_dt;


-- -----------------------------------------------------------------------------
-- Business Rule:
-- Sales = Quantity × Price
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    sls_ord_num,
    sls_prd_key,
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;


-- -----------------------------------------------------------------------------
-- Check for Negative or Zero Quantity
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_quantity <= 0
   OR sls_quantity IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Negative or Zero Price
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.crm_sales_details
WHERE sls_price <= 0
   OR sls_price IS NULL;


-- =============================================================================
-- ERP: silver.erp_cust_az12
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.erp_cust_az12';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Customer ID
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cid,
    COUNT(*) AS record_count
FROM silver.erp_cust_az12
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Out-of-Range Birth Dates
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE();


-- -----------------------------------------------------------------------------
-- Data Standardization and Consistency
-- Expectation: Male, Female, n/a
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    gen
FROM silver.erp_cust_az12;


-- -----------------------------------------------------------------------------
-- Check for Invalid Gender Values
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a')
   OR gen IS NULL;


-- =============================================================================
-- ERP: silver.erp_loc_a101
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.erp_loc_a101';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Customer ID
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cid,
    COUNT(*) AS record_count
FROM silver.erp_loc_a101
GROUP BY cid
HAVING COUNT(*) > 1
    OR cid IS NULL;


-- -----------------------------------------------------------------------------
-- Data Standardization and Consistency
-- Expectation: Review the distinct countries
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces in Country
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cntry
FROM silver.erp_loc_a101
WHERE cntry != TRIM(cntry);


-- -----------------------------------------------------------------------------
-- Check for NULL Country Values
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_loc_a101
WHERE cntry IS NULL;


-- =============================================================================
-- ERP: silver.erp_px_cat_g1v2
-- =============================================================================

PRINT '==========================================================';
PRINT 'Checking silver.erp_px_cat_g1v2';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    id,
    COUNT(*) AS record_count
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1
    OR id IS NULL;


-- -----------------------------------------------------------------------------
-- Check for Unwanted Spaces
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);


-- -----------------------------------------------------------------------------
-- Data Standardization and Consistency
-- Expectation: Review distinct values
-- -----------------------------------------------------------------------------

SELECT DISTINCT
    cat
FROM silver.erp_px_cat_g1v2;


SELECT DISTINCT
    subcat
FROM silver.erp_px_cat_g1v2;


SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2;


-- =============================================================================
-- CROSS-TABLE / REFERENTIAL CHECKS
-- =============================================================================

PRINT '==========================================================';
PRINT 'Cross-Table Quality Checks';
PRINT '==========================================================';


-- -----------------------------------------------------------------------------
-- Check whether ERP customer IDs exist in CRM customer table
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cid
FROM silver.erp_cust_az12
WHERE cid NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);


-- -----------------------------------------------------------------------------
-- Check whether ERP location customer IDs exist in CRM customer table
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    cid
FROM silver.erp_loc_a101
WHERE cid NOT IN (
    SELECT cst_key
    FROM silver.crm_cust_info
);


-- -----------------------------------------------------------------------------
-- Check whether Product IDs from ERP category table exist
-- in CRM product table
-- Expectation: No result
-- -----------------------------------------------------------------------------

SELECT
    id
FROM silver.erp_px_cat_g1v2
WHERE id NOT IN (
    SELECT cat_id
    FROM silver.crm_prd_info
);


-- =============================================================================
-- END OF QUALITY CHECKS
-- =============================================================================

PRINT '==========================================================';
PRINT 'Silver Layer Quality Checks Completed';
PRINT '==========================================================';

