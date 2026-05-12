# ReadMe – Walmart Data Warehouse Project

## Project Components

1. Create-DW.sql – SQL script to create the Data Warehouse (DW) star schema.
2. Hybrid-Join.py – Python program implementing the HYBRIDJOIN ETL algorithm.
3. OLAP_Queries.sql – SQL script containing all OLAP queries for analysis.
4. Project-Report.docx – Report explaining the DW design, HYBRIDJOIN algorithm, and query analysis.

## Step-by-Step Instructions to Operate the Project

### 1. Setup the Database

1. Install MySQL Server and MySQL Workbench (or any MySQL client).
2. Open MySQL Workbench and connect to your local server.
3. Run Create-DW.sql to create the star schema for the data warehouse.

   * This script drops existing tables if any, creates all dimension and fact tables, and sets up primary & foreign keys.
4. Verify that tables `customer_dim`, `product_dim`, `store_dim`, `supplier_dim`, `date_dim`, and `fact_sales` are created.

### 2. Prepare Data Files

1. Place the following CSV files in the same directory as Hybrid-Join.py:

   * customer_master_data.csv
   * product_master_data.csv
   * transactional_data.csv
2. Ensure the CSVs match the required columns:

   * customer_master_data.csv: Customer_ID, Gender, Age, Occupation, City_Category, Stay_In_Current_City_Years, Marital_Status
   * product_master_data.csv: Product_ID, Product_Category, price$, storeID, supplierID, storeName, supplierName
   * transactional_data.csv: orderID, Customer_ID, Product_ID, quantity, date

### 3. Run the HybridJoin ETL

1. Open a terminal/command prompt in the project directory.
2. Run the Python program:

```
python Hybrid-Join.py
```

3. The program will:

   * Load master data (customers & products)
   * Read transactional data in chunks using a stream buffer
   * Perform HYBRIDJOIN ETL to populate fact_sales table
   * Insert missing dimension records dynamically
   * Commit batches of rows to the DW
4. Monitor terminal output for progress updates.

### 4. Execute OLAP Queries

1. Open OLAP_Queries.sql in MySQL Workbench.
2. Run the queries one by one or all at once to get insights, including:

   * Top products by revenue per month/weekend/weekday
   * Customer demographics vs purchase amount
   * Product-category vs occupation analysis
   * Revenue trends per store, supplier, and product
   * Seasonal sales, spikes, and quarterly summaries
3. Query results can be exported as CSV for further analysis or reporting.

### 5. Verify Data

* Check fact_sales table to confirm all transactional records are loaded.
* Check dimension tables to ensure all master data has been inserted correctly.

### Notes

* Ensure Python 3.x is installed with `pandas`, `mysql-connector-python` libraries:

```
pip install pandas mysql-connector-python
```

* Make sure MySQL server credentials in Hybrid-Join.py are correct:

```python
db_config = {
    'user': 'root',
    'password': '123456',
    'host': 'localhost',
    'database': 'my_dw'
}
```

* The ETL is safe for re-runs; it checks for existing records to prevent duplicates.

**End of ReadMe**
