# 📊 Data Warehousing & Analytics Project

This project is a modern data warehousing and analytics solution focused on ingesting, transforming, and delivering business-ready insights using a structured medallion architecture. It integrates multiple data sources, improves data quality, and supports analytical querying through well-defined layers and processes.

---

## ✅ Project Overview

The project is organized into **three key epics**:

---

### 1. 📌 Requirements Analysis

This phase focuses on understanding business needs and aligning the data strategy accordingly.

- **Data Sources**: Enterprise Resource Planning (ERP) and Customer Relationship Management (CRM) systems.  
- **Data Quality**: Cleanse and resolve data inconsistencies before analysis.  
- **Data Integration**: Merge multiple sources into a unified, analytics-ready model.  
- **Scope**: Focus on the **latest datasets** to reduce latency and complexity.  
- **Documentation**: Provide clear, accessible documentation for both business users and analysts.

---

### 2. 🧱 Data Architecture Design

A **Data Warehouse** was chosen as the core architecture, implemented using the **Medallion Architecture**, which structures data into three refined layers:

#### 🥉 Bronze Layer – Raw Ingestion
- **Load Type**: Full Load  
- **Purpose**: Store raw, unprocessed data directly from sources for traceability, auditing, and debugging.  
- **Process**:
  - Tables created to mirror original CRM and ERP sources.
  - Data ingested using `BULK INSERT` from CSV files stored in the file system (`C:\sqldata\staging`).
  - Use of `CHECK_CONSTRAINTS` and `FIRSTROW` options to control data validity and format.
  - Example Table: `bronze.crm_cust_info`, `bronze.erp_px_cat_g1v2`

#### 🥈 Silver Layer – Cleansed & Enriched
- **Load Type**: Full Load  
- **Purpose**: Store cleaned, standardized data that’s ready for integration.  
- **Processes**:
  - Null handling, removal of duplicates, and type conversions.
  - Derived columns such as `full_name`, concatenated address fields, formatted phone numbers, etc.
  - Standardized timestamps (`dwh_create_date`) added for traceability.
  - All transformations are done in stored procedures like `silver.load_silver`.
  - Example Tables: `silver.crm_cust_info`, `silver.crm_transactions`, `silver.erp_products`

#### 🥇 Gold Layer – Business-Ready Data
- **Load Type**: Aggregated and Integrated  
- **Purpose**: Serve reporting tools with business-contextualized data.  
- **Processes**:
  - Business logic applied using SQL joins, aggregations, and case statements.
  - Creation of star schema: Fact and dimension tables.
  - KPI calculations such as customer transaction value, product category performance, etc.
  - Ready for BI tools like Power BI or Tableau.

  ![High Level Architecture](docs/High%20Level%20Architecture.jpg)

---

### 3. 🛠️ Project Initialization

- **Task Management**: All planning and sprint tracking was done using **Notion**.
- **Naming Conventions**: Adopted snake_case for tables and fields for consistency (e.g., `crm_cust_info`, `dwh_create_date`).
- **Version Control**: Used GitHub to track changes in SQL scripts, stored procedures, and documentation.
- **Permissions & Environment Setup**:
  - Used SQL Server Express.
  - File access permission granted to SQL Server service account.
  - Manual creation of directory: `C:\sqldata\staging`

---

## 💡 Technical Implementation Highlights

- **Stored Procedures**: 
  - Modular design for loading each layer (`silver.load_silver`).
  - Error handling implemented using `TRY...CATCH`.
  - Execution timestamp tracking via `@batch_start_time` and `@batch_end_time`.

- **Performance Optimization**:
  - Bulk insert operations for faster ingestion.
  - Drop-and-recreate strategy in bronze layer to ensure data freshness.
  - Light transformations in silver layer to prepare data for analytical use.

- **Best Practices Applied**:
  - Layered medallion architecture
  - Consistent commenting and documentation inside SQL files
  - Use of staging directories for decoupling data source from pipeline logic

---

## 📈 Target Outcomes

- A scalable, traceable data warehouse system  
- Unified and analytics-ready datasets  
- Optimized reporting pipeline to drive business insights  
- BI integration through tools like Power BI or Tableau

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🙋 About Me

**Odoh Kenneth Chidiebere**  
I’m a passionate data enthusiast with a strong interest in data engineering and analytics. I enjoy solving real-world problems using structured data solutions and modern analytical tools. Let’s connect and build the future of data together!
