/*
=================================================
Stored Procedure: Load Silver Layer
=================================================
Script Purpose:
    This stored procedure loads and cleans data
    from the Bronze layer into the Silver layer.

    The procedure:
    - Truncates existing Silver tables
    - Cleans and transforms Bronze data
    - Inserts the cleaned data into Silver tables
    - Displays load duration
    - Handles errors using TRY...CATCH

=================================================
*/


CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
    BEGIN TRY
        
        SET @batch_start_time = GETDATE()

        PRINT '==========================================================';
        PRINT 'Loading Silver Layer';
        PRINT '==========================================================';
        
        PRINT '----------------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------------------------';


    -- Load silver.crm_cust_info
    SET @start_time = GETDATE();
    TRUNCATE TABLE silver.crm_cust_info
    PRINT '>> Inserting Data Into: silver.crm_cust_info'

    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )

    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,
        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,
        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            WHEN UPPER(TRIM(cst_gndr)) = 'F'  THEN 'Female'
            ELSE 'n/a'
        END AS cst_gndr,
        cst_create_date
    FROM 
    (
    SELECT 
    *,
    ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.crm_cust_info
    ) AS t
    WHERE flag_last = 1 AND cst_id IS NOT NULL;

    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='







    -- Build Silver Layer Clean & Load crm_prd_info


    --Check for nulls or duplicates in primary key
    -- Expection: No result


    -- SELECT 
    --     prd_id,
    --     COUNT(*)
    -- FROM bronze.crm_prd_info
    -- GROUP BY prd_id
    -- HAVING COUNT(*) > 1 OR prd_id IS NULL;

    -- Loading silver.crm_prd_info

    -- Load crm_prd_info
    SET @start_time = GETDATE()
    PRINT '>> Truncating Table: silver.crm_prd_info'
    TRUNCATE TABLE silver.crm_prd_info
    PRINT '>> Inserting Data Into: silver.crm_prd_info'

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT 
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
    prd_nm,
    ISNULL(prd_cost, 0) AS prd_cost,
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'n/a'
    END AS prd_line,
    CAST(prd_start_dt AS DATE) AS prd_start_dt,
    CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS DATE) AS prd_end_dt
    FROM bronze.crm_prd_info
    WHERE SUBSTRING(prd_key, 7, LEN(prd_key)) IN (
    SELECT sls_prd_key
    FROM bronze.crm_sales_details
    )

    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='


    -- SELECT DISTINCT 
    -- id
    -- FROM bronze.erp_px_cat_g1v2


    -- SEL  ECT sls_prd_key
    -- FROM bronze.crm_sales_details


    -- Check for unwanted spaces 
    -- Expection: No result

    -- SELECT prd_nm
    -- FROM bronze.crm_prd_info
    -- WHERE prd_nm != TRIM(prd_nm)


    -- Check for NULLs or Negative Numbers
    -- Expecttion: No result

    -- SELECT prd_cost
    -- FROM bronze.crm_prd_info
    -- WHERE prd_cost IS NULL OR prd_cost < 0


    -- Data Standarization and consitency

    -- SELECT DISTINCT 
    -- prd_line
    -- FROM bronze.crm_prd_info



    -- Check for Invalid Date Orders

    -- SELECT * 
    -- FROM bronze.crm_prd_info
    -- WHERE prd_start_dt > prd_end_dt


    -- USE DataWarehouse;

    -- SELECT 
    -- prd_id,
    -- prd_key,
    -- prd_nm,
    -- prd_start_dt,
    -- prd_end_dt,
    -- LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) -1 AS next_prd_start_dt
    -- FROM bronze.crm_prd_info
    -- WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509-R')





    --- BUILD SILVER LAYER 
    --- CLEAN & LOAD 
    --- crm_sales_details


    -- Loading silver.crm_prd_info



    -- Load crm_sales_details
    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.crm_sales_details';
    TRUNCATE TABLE silver.crm_sales_details
  
    TRUNCATE TABLE silver.crm_sales_details
    PRINT '>> Inserting Data Into: silver.crm_sales_details';


    INSERT INTO silver.crm_sales_details(
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )


    SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt  = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt  = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,
    CASE  
        WHEN sls_due_dt  = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,
    CASE 
        WHEN sls_sales IS NULL or sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
    FROM bronze.crm_sales_details
    
    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='





    -- CHECKING FOR sls_ord_dates 


    -- SELECT 
    -- NULLIF(sls_order_dt, 0) AS sls_order_dt
    -- FROM bronze.crm_sales_details
    -- WHERE 
    -- sls_order_dt <= 0 
    -- OR LEN(sls_order_dt) != 8
    -- OR sls_order_dt > 20500101
    -- OR sls_order_dt < 19900101



    -- -- CHECKING FOR sls_ship_dates 

    -- SELECT 
    -- NULLIF(sls_ship_dt, 0) AS sls_ship_dt
    -- FROM bronze.crm_sales_details
    -- WHERE 
    -- sls_ship_dt <= 0 
    -- OR LEN(sls_ship_dt) != 8
    -- OR sls_ship_dt > 20500101
    -- OR sls_ship_dt < 19900101



    -- -- CHECKING FOR sls_due_dates 

    -- SELECT 
    -- NULLIF(sls_due_dt, 0) AS sls_due_dt
    -- FROM bronze.crm_sales_details
    -- WHERE 
    -- sls_due_dt <= 0 
    -- OR LEN(sls_due_dt) != 8
    -- OR sls_due_dt > 20500101
    -- OR sls_due_dt < 19900101




    -- -- Check for Invalid Date Orders

    -- SELECT * 
    -- FROM bronze.crm_sales_details
    -- WHERE sls_order_dt > sls_due_dt OR sls_order_dt > sls_ship_dt 




    -- -- Business Rule 
    -- -- Sum(Sakes) = Quantity * Price)
    -- -- Negative, Zero, or NULL values are not allowed in Quantity and Price columns

    -- SELECT 
    -- sls_sales AS sls_old_sales,
    -- sls_quantity,
    -- sls_price AS sls_old_price,
    -- CASE 
    --     WHEN sls_sales IS NULL or sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
    --     THEN sls_quantity * ABS(sls_price)
    --     ELSE sls_sales
    -- END AS sls_sales,

    -- CASE
    --     WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
    --     ELSE sls_price
    -- END AS sls_price
    -- FROM bronze.crm_sales_details
    -- WHERE sls_sales IS NULL 
    -- OR sls_quantity IS NULL 
    -- OR sls_price IS NULL 
    -- OR sls_sales <= 0 
    -- OR sls_quantity <= 0 
    -- OR sls_price <= 0 
    -- OR sls_sales != sls_quantity * sls_price




    -- BUILD SILVER LAYER 
    -- CLEAN & LOAD 
    -- erp_cust_az12


    -- Load erp_cust_az12
    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_cust_az12';
    TRUNCATE TABLE silver.erp_cust_az12
  
    TRUNCATE TABLE silver.erp_cust_az12
    PRINT '>> Inserting Data Into: silver.erp_cust_az12 '

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )

    SELECT 
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END AS cid, 
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate 
    END AS bdate,
    CASE 
        WHEN UPPER(TRIM(
                    REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), '')
        )) IN ('M', 'MALE') 
        THEN 'Male'

        WHEN UPPER(TRIM(
                    REPLACE(REPLACE(gen, CHAR(13), ''), CHAR(10), '')
        )) IN ('F', 'FEMALE') 
        THEN 'Female'

        ELSE 'n/a'
    END AS gen
    FROM bronze.erp_cust_az12

    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='





    -- WHERE CASE 
    --     WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
    --     ELSE cid
    -- END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)





    -- CHECKING cid from silver.crm_cust_info 

    -- SELECT * FROM silver.crm_cust_info


    -- Identify Out-of-Range Dates

    -- USE DataWarehouse;

    -- SELECT DISTINCT 
    -- bdate
    -- FROM bronze.erp_cust_az12
    -- WHERE bdate < '1924-01-01' OR bdate > GETDATE()



    -- SELECT DISTINCT gen 
    -- FROM bronze.erp_cust_az12






    -- BUILD SILVER LAYER
    -- CLEAN & LOAD
    -- erp_px_cat_g1v2





    -- Load erp_loc_a101
    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_loc_a101';
    TRUNCATE TABLE silver.erp_cust_az12

    TRUNCATE TABLE silver.erp_loc_a101
    PRINT '>> Inserting Data Into: silver.erp_loc_a101 '

    INSERT INTO silver.erp_loc_a101(
        cid,
        cntry
    )


    SELECT 
        REPLACE(cid, '-', '') AS cid,
        CASE  
            WHEN REPLACE(TRIM(cntry), CHAR(13), '') = 'DE' THEN 'Germany'
            WHEN REPLACE(TRIM(cntry), CHAR(13), '') IN ('US', 'USA') THEN 'United States'
            WHEN REPLACE(TRIM(cntry), CHAR(13), '') IS NULL THEN 'n/a'
            ELSE cntry
        END AS cntry
    FROM bronze.erp_loc_a101 

    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='






    -- WHERE REPLACE(cid, '-', '') NOT IN 
    -- (SELECT 
    --     cst_key 
    -- FROM silver.crm_cust_info)



    -- DATA STANDARIDATION AND CONSISTENCY
    -- SELECT DISTINCT 
    --     cntry
    -- FROM bronze.erp_loc_a101
    -- ORDER BY cntry




    -- Build Silver Layer
    -- Cleann & Lead
    -- erp_px_cat_g1v2


    -- Load erp_px_cat_g1v2
    
    SET @start_time = GETDATE();
    PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
    TRUNCATE TABLE silver.erp_px_cat_g1v2


    TRUNCATE TABLE silver.erp_px_cat_g1v2
    PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2 '

    INSERT INTO silver.erp_px_cat_g1v2
    (id,
    cat,
    subcat,
    maintenance)

    SELECT 
    id,
    cat,
    subcat,
    maintenance
    FROM bronze.erp_px_cat_g1v2 

    SET @end_time = GETDATE()
    PRINT '>> Load Duration:' + CAST(DATEDIFF(SECOND, @start_time, @end_time) As NVARCHAR) + 'seconds'
    PRINT '============================================='




    -- -- CHECK FOR UNWANTED SPACES 
    -- SELECT * FROM bronze.erp_px_cat_g1v2
    -- WHERE cat != TRIM(cat)


    -- SELECT * FROM bronze.erp_px_cat_g1v2
    -- WHERE subcat != TRIM(subcat)


    -- -- Data Standardization and Consistency
    -- SELECT DISTINCT 
    -- cat 
    -- FROM bronze.erp_px_cat_g1v2

    -- WHERE id NOT IN 
    -- (SELECT 
    -- cat_id
    -- FROM silver.crm_prd_info)


    END TRY 
    BEGIN CATCH 
        PRINT '==========================================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '==========================================================';
    END CATCH

END



