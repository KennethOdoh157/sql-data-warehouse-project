# 📚 **Data Dictionary for Gold Layer**

## 📊 **Gold Layer Overview**
The **Gold Layer** represents **business-level data**, structured to support **analytical and reporting use cases**.  
It consolidates and enriches data from lower layers into well-defined **dimension** and **fact** tables optimized for **decision-making** and **insight generation**.

---

## 🧍‍♂️ **Dimension Table: `gold.dim_customers`**

| **Column Name**     | **Data Type** | **Description**                                                                           |
|---------------------|---------------|-------------------------------------------------------------------------------------------|
| `customer_key`      | INT           | A surrogate key uniquely identifying each customer record in the dimension table.        |
| `customer_id`       | INT           | A unique numeric identifier assigned to every customer.                                  |
| `customer_number`   | NVARCHAR(50)  | An alphanumeric code representing the customer, used for tracking and reference purposes.|
| `first_name`        | NVARCHAR(50)  | The customer's given name as stored in the system.                                       |
| `last_name`         | NVARCHAR(50)  | The customer's surname or family name.                                                   |
| `country`           | NVARCHAR(50)  | The customer's country of residence (e.g., 'Australia').                                 |
| `marital_status`    | NVARCHAR(50)  | Indicates the marital status of the customer (e.g., 'Married', 'Single').                |
| `gender`            | NVARCHAR(50)  | Specifies the customer's gender (e.g., 'Male', 'Female', 'n/a').                         |
| `birthdate`         | DATE          | The customer's date of birth in 'YYYY-MM-DD' format (e.g., 1971-10-06).                  |
| `create_date`       | DATE          | The timestamp when the customer record was created in the system.                        |

---

## 📦 **Dimension Table: `gold.dim_products`**

| **Column Name**          | **Data Type** | **Description**                                                                              |
|--------------------------|---------------|----------------------------------------------------------------------------------------------|
| `product_key`            | INT           | Surrogate key uniquely identifying each product record in the dimension table.              |
| `product_id`             | INT           | Unique identifier assigned to the product for internal tracking.                            |
| `product_number`         | NVARCHAR(50)  | Alphanumeric code used to represent the product for categorization or inventory management. |
| `product_name`           | NVARCHAR(50)  | Name of the product, including descriptive details like type, color, and size.              |
| `category_id`            | NVARCHAR(50)  | Identifier linking the product to its main category.                                        |
| `category`               | NVARCHAR(50)  | Broad classification of the product (e.g., Bikes, Components).                             |
| `subcategory`            | NVARCHAR(50)  | A more specific classification within the category, detailing product types.               |
| `maintenance_required`   | NVARCHAR(50)  | Indicates if the product needs maintenance (e.g., 'Yes', 'No').                             |
| `cost`                   | INT           | Base cost of the product, recorded in monetary units.                                       |
| `product_line`           | NVARCHAR(50)  | The product line or series it belongs to (e.g., Road, Mountain).                           |
| `start_date`             | DATE          | The availability date of the product in the system.                                         |

---

## 💰 **Fact Table: `gold.fact_sales`**

| **Column Name**     | **Data Type** | **Description**                                                                          |
|---------------------|---------------|------------------------------------------------------------------------------------------|
| `order_number`      | NVARCHAR(50)  | Unique alphanumeric identifier for each sales order (e.g., 'SO54496').                  |
| `product_key`       | INT           | Surrogate key that links the sale to the product dimension table.                       |
| `customer_key`      | INT           | Surrogate key that connects the sale to the customer dimension table.                   |
| `order_date`        | DATE          | Date when the order was placed.                                                         |
| `shipping_date`     | DATE          | Date when the order was shipped to the customer.                                        |
| `due_date`          | DATE          | Date by which payment for the order was due.                                            |
| `sales_amount`      | INT           | Total value of the sale for the line item, in whole currency units (e.g., 25).          |
| `quantity`          | INT           | Number of units of the product ordered in the line item (e.g., 1).                      |
| `price`             | INT           | Unit price of the product for the line item, in whole currency units (e.g., 25).        |

---


