/*
===============================================================================
Stored Procedure: Initialize Bronze Tables (CRM and ERP Sources)
===============================================================================

Script Purpose:
    This stored procedure creates fresh tables under the 'bronze' schema 
    for CRM and ERP source systems. It performs the following tasks:
    - Drops existing bronze tables if they already exist.
    - Creates new base tables for customers, products, sales, locations, 
      and price categories.

Parameters:
    None.
    This procedure does not require any input parameters or return any output.

Usage Example:
    EXEC bronze.load_bronze;
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
	SET @batch_start_time = GETDATE();
		PRINT '=============================================================';
		PRINT 'Loading bronze Table';
		PRINT '=============================================================';

		PRINT '-------------------------------------------------------------';
		PRINT 'Loading CRM Table';
		PRINT '-------------------------------------------------------------';
	
		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Inserting data into: bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_crm\cust_info.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
		PRINT '>> Truncation Table: bronze.crm_cust_info';
		
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting data into:bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_crm\prd_info.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '-----------------';
		PRINT '>> Truncation Table: bronze.crm_prd_info';
		

		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT '>> Inserting data into:bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_crm\sales_details.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
		PRINT '>> Truncation Table: crm_sales_details';
		
	
		PRINT '-------------------------------------------------------------';
		PRINT 'Loading ERP Table';
		PRINT '-------------------------------------------------------------';
	
		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT '>> Inserting data into:bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
		PRINT '>> Truncation Table: bronze.erp_cust_az12';
		

		SET @start_time = GETDATE();
		PRINT '>> Truncation Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting data into:bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
		PRINT '>> Truncation Table: bronze.erp_loc_a101';
		

		SET @start_time = GETDATE();
		PRINT '>> Truncation Table:bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting data into:bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM "C:\Users\Kenjo\OneDrive\Documents\30_hours sql course materials\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv"
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '----------------';
		PRINT '>> Truncation Table: bronze.erp_px_cat_g1v2';
		
		SET @batch_end_time = GETDATE();
		PRINT '============================================';
		PRINT 'Loading Bronze Layer is Completed';
		PRINT '   - Total Duration:' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '============================================';
	END TRY
	BEGIN CATCH
		PRINT '============================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=============================================';
	END CATCH
END

