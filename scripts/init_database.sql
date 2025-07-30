/*
===========================================================
Create Database and Schemas
===========================================================
📝 SCRIPT PURPOSE:
This script initializes a fresh data warehouse environment
by performing the following actions:

1. Switches to the 'master' database context.
2. Checks for the existence of a database named 'Datawarehouse'.
3. If it exists, forcibly drops it after setting SINGLE_USER mode
   to disconnect any active connections.
4. Recreates the 'DataWarehouse' database.
5. Creates the following schemas within the new database:
   - bronze: for raw, unprocessed data
   - silver: for cleansed and standardized data
   - gold: for business-ready, analytics-friendly data

⚠️ WARNING:
This script will **permanently delete** the existing 'Datawarehouse' database
if it already exists, along with **all data and objects** inside it.
Ensure you have **proper backups** and the **correct permissions** before executing.
This script is meant for **initial setup or development purposes** —
use with caution in production environments.
===========================================================
*/
USE master;
GO
  
--Drop and recreate the 'Datawarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Datawarehouse')
BEGIN
	ALTER DATABASE Datawarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Datawarehouse;
END;
GO

--create the 'Datawarehouse' database
CREATE DATABASE DataWarehouse;
GO
  
USE DataWarehouse;
GO

--create schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

