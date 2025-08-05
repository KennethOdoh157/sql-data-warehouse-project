/*
===============================================================================
Script Name:     data_quality_tests.sql
Purpose:         
    This script performs data quality checks on staging tables in the 'bronze' 
    schema before data is transformed and inserted into the 'silver' layer.

    It targets the following tables:
        - bronze.crm_cust_info
        - bronze.crm_prd_info
        - bronze.crm_sales_details
        - bronze.erp_cust_az12
        - bronze.erp_loc_a101
        - bronze.erp_px_cat_g1v2

    The checks include:
        - NULLs in critical fields
        - Duplicates in primary or business key columns
        - Invalid or inconsistent values where applicable

    These validations help ensure data integrity before transformation or 
    loading into downstream layers.

Usage Notes:
- Run this script after staging data has been loaded.
- Modify column names or validation logic to fit future schema changes.
- Script is designed for Microsoft SQL Server.
===============================================================================
*/

-- =================================
-- Test for bronze.crm_cust_info
-- =================================
PRINT '--- Testing bronze.crm_cust_info ---';

PRINT 'Checking NULLs in [cst_id], [cst_key], [cst_firstname], [cst_lastname]...';
SELECT *
FROM bronze.crm_cust_info
WHERE cst_id IS NULL OR cst_key IS NULL OR cst_firstname IS NULL OR cst_lastname IS NULL;

PRINT 'Checking for duplicate [cst_id]...';
SELECT cst_id, COUNT(*) AS cnt
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- =================================
-- Test for bronze.crm_prd_info
-- =================================
PRINT '--- Testing bronze.crm_prd_info ---';

PRINT 'Checking NULLs in [prd_id], [prd_key], [prd_nm], [prd_cost]...';
SELECT *
FROM bronze.crm_prd_info
WHERE prd_id IS NULL OR prd_key IS NULL OR prd_nm IS NULL OR prd_cost IS NULL;

PRINT 'Checking for invalid [prd_cost] < 0...';
SELECT *
FROM bronze.crm_prd_info
WHERE prd_cost < 0;

PRINT 'Checking for duplicate [prd_id]...';
SELECT prd_id, COUNT(*) AS cnt
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1;

-- ========================================
-- Test for bronze.crm_sales_details
-- ========================================
PRINT '--- Testing bronze.crm_sales_details ---';

PRINT 'Checking NULLs in [sls_ord_num], [sls_prd_key], [sls_cust_id]...';
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num IS NULL OR sls_prd_key IS NULL OR sls_cust_id IS NULL;

PRINT 'Checking for invalid [sls_order_dt], [sls_ship_dt], [sls_due_dt]...';
SELECT *
FROM bronze.crm_sales_details
WHERE LEN(CAST(sls_order_dt AS VARCHAR)) != 8 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8;

PRINT 'Checking for [sls_sales] not matching quantity * price...';
SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * ABS(sls_price);

PRINT 'Checking for negative or zero [sls_price]...';
SELECT *
FROM bronze.crm_sales_details
WHERE sls_price <= 0;

-- ==================================
-- Test for bronze.erp_cust_az12
-- ==================================
PRINT '--- Testing bronze.erp_cust_az12 ---';

PRINT 'Checking NULLs in [cid], [gen]...';
SELECT *
FROM bronze.erp_cust_az12
WHERE cid IS NULL OR gen IS NULL;

PRINT 'Checking for [bdate] in the future...';
SELECT *
FROM bronze.erp_cust_az12
WHERE bdate > GETDATE();

-- =================================
-- Test for bronze.erp_loc_a101
-- =================================
PRINT '--- Testing bronze.erp_loc_a101 ---';

PRINT 'Checking NULLs in [cid], [cntry]...';
SELECT *
FROM bronze.erp_loc_a101
WHERE cid IS NULL OR cntry IS NULL;

PRINT 'Checking for inconsistent [cntry] values...';
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

-- =====================================
-- Test for bronze.erp_px_cat_g1v2
-- =====================================
PRINT '--- Testing bronze.erp_px_cat_g1v2 ---';

PRINT 'Checking NULLs in [id], [cat], [subcat]...';
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE id IS NULL OR cat IS NULL OR subcat IS NULL;

PRINT 'Checking for duplicate [id]...';
SELECT id, COUNT(*) AS cnt
FROM bronze.erp_px_cat_g1v2
GROUP BY id
HAVING COUNT(*) > 1;
