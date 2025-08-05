/*
====================================================================================================
  Procedure: silver.load_silver
  Author: [Your Name or Team Name]
  Description:
      This stored procedure performs the full data load process from the 'bronze' (raw) schema 
      into the 'silver' (cleansed) schema of the data warehouse.

      Each table in the silver layer is truncated and repopulated using business and data 
      quality logic such as:
        - Value standardization (e.g., gender, marital status, country names)
        - Null handling and type correction (e.g., birthdates, pricing fields)
        - Transformation rules (e.g., deriving category IDs, recalculating sales/price)
        - Window functions for deduplication and lead-date inference
        - Logging of load durations for performance observability
  Parameters:
      None.
      This stored procedure does not accept any parameter or return any value
  Usage Example:
      EXEC silver.load_silver

====================================================================================================
*/
EXEC silver.load_silver
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=============================================================';
		PRINT 'Loading silver Table';
		PRINT '=============================================================';

		PRINT '-------------------------------------------------------------';
		PRINT 'Loading CRM Table';
		PRINT '-------------------------------------------------------------';

		-- Load CRM Customer Info
		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT '>> Inserting Data Into: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname),
			TRIM(cst_lastname),
			-- Standardize marital status values
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END,
			-- Standardize gender values
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END,
			cst_create_date
		FROM (
			SELECT 
				*, 
				-- Flag the latest record per customer based on creation date
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		-- Only return the latest record for each customer
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';


		-- Load CRM Product Info
		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info
		PRINT '>> Inserting Data Into: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
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
		-- Derive category ID from prefix of product key
		REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
		-- Extract actual product key
		SUBSTRING(prd_key, 7, LEN(prd_key)),
		prd_nm,
		ISNULL(prd_cost, 0),
		-- Map product line codes to full names
		CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road' 
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a'
		END,
		CAST(prd_start_dt AS DATE),
		-- Infer product end date as the day before the next start date
		CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE)
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';


		-- Load CRM Sales Details
		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: silver.crm_sales_details';
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
		-- Parse dates only if in expected 8-digit format
		CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8
			THEN NULL
			ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END,
		CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8
			THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END,
		CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8
			THEN NULL
			ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END,
		-- Recalculate sales if inconsistent or missing
		CASE WHEN sls_sales <=0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
			THEN sls_quantity * ABS(sls_price)
			ELSE sls_sales
		END,
		sls_quantity,
		-- Recalculate price if invalid
		CASE WHEN sls_price <= 0 OR sls_price IS NULL  
			THEN sls_sales / NULLIF(sls_quantity, 0)
			ELSE sls_price
		END
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';


		PRINT '-------------------------------------------------------------';
		PRINT 'Loading ERP Table';
		PRINT '-------------------------------------------------------------';

		-- Load ERP Customer Info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT '>> Inserting Data Into: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
		SELECT 
		-- Normalize customer ID by removing 'NAS' prefix
		CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
			ELSE cid
		END,
		-- Remove birthdates in the future
		CASE WHEN bdate > GETDATE() THEN NULL
			ELSE bdate
		END,
		-- Standardize gender values
		CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
			WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
			ELSE 'n/a'
		END
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';


		-- Load ERP Location Info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT '>> Inserting Data Into: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT 
		REPLACE(cid, '-', ''),
		-- Standardize country names
		CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
			WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
			WHEN TRIM(cntry) IS NULL OR cntry = '' THEN 'n/a'
			ELSE TRIM(cntry)
		END
		FROM bronze.erp_loc_a101
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';


		-- Load ERP Product Category Info
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintenance)
		SELECT
		id,
		cat,
		subcat,
		maintenance
		FROM bronze.erp_px_cat_g1v2;
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';

		SET @batch_end_time = GETDATE();
		PRINT '============================================';
		PRINT 'Loading Silver Layer is Completed';
		PRINT '   - Total Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '============================================';
	END TRY
	BEGIN CATCH
		PRINT '===== ERROR =====';
		PRINT 'Message: ' + ERROR_MESSAGE();
		PRINT 'Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Severity: ' + CAST(ERROR_SEVERITY() AS NVARCHAR);
		PRINT 'State: ' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT 'Line: ' + CAST(ERROR_LINE() AS NVARCHAR);
		PRINT 'Procedure: ' + ISNULL(ERROR_PROCEDURE(), 'N/A');
		PRINT '=================';
	END CATCH
END
