/*
============================================================
Gold Layer Data Quality Validation Script
============================================================

Purpose:
    - To validate the integrity and quality of data in the gold layer views used for reporting.
    - To check for duplicates, transformation logic, and referential integrity between tables.

Targeted Tables:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales
    - silver.crm_cust_info
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.crm_prd_info
    - silver.erp_px_cat_g1v2
============================================================
*/

-- =========================
-- dim_customers Test Queries
-- =========================

-- Check for duplicate customer records in source data
SELECT cst_id, COUNT(*)
FROM (
    SELECT ci.cst_id, ci.cst_key, ci.cst_firstname, ci.cst_lastname,
           ci.cst_marital_status, ci.cst_gndr, ci.cst_create_date,
           ca.bdate, ca.gen, la.cntry
    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
) t 
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Validate gender logic implementation
SELECT DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
         ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la ON ci.cst_key = la.cid
ORDER BY 1, 2;

-- Basic view validation
SELECT * FROM gold.dim_customers;

-- Check distinct gender values in final view
SELECT DISTINCT gender FROM gold.dim_customers;

-- =========================
-- dim_products Test Queries
-- =========================

-- Check for duplicate product records in source data
SELECT prd_key, COUNT(*) 
FROM (
    SELECT pn.prd_id, pn.cat_id, pn.prd_key, pn.prd_nm,
           pn.prd_cost, pn.prd_line, pn.prd_start_dt,
           pc.cat, pc.subcat, pc.maintenance
    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.cat_id = pc.id
    WHERE prd_end_dt IS NULL
) t 
GROUP BY prd_key
HAVING COUNT(*) > 1;

-- Basic view validation
SELECT * FROM gold.dim_products;

-- =======================
-- fact_sales Test Queries
-- =======================

-- Basic view validation
SELECT * FROM gold.fact_sales;

-- Foreign key integrity check (both dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
