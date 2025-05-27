# ETL Project: Sakila to Rental Film Data Warehouse

This project outlines an Extract, Transform, Load (ETL) process to populate a dimensional data warehouse (`rental_film_dw`) from the `sakila` transactional database.

## 1. Project Goal

To build a star-schema data warehouse for analytical reporting on film rental data, enabling insights into payments, staff performance, film popularity, and inventory levels.

## 2. Architecture

- **Source:** `sakila` MySQL OLTP Database
- **Target:** `rental_film_dw` MySQL OLAP Data Warehouse (Star Schema)
- **Tooling:** Python (Pandas, SQLAlchemy, PyMySQL)

## 3. Data Warehouse Schema

The `rental_film_dw` is structured with several dimension tables and two fact tables:

- **Dimension Tables:**
  - `Dim_Date`: Time-based attributes (generated)
  - `Dim_Staff`: Staff information
  - `Dim_Film`: Film details
  - `Dim_Store`: Store information
  - `Dim_Rent`: Rental transaction details
- **Fact Tables:**
  - `Fact_Monthly_Payment`: Aggregated payment information per staff, per rental, per month.
  - `Fact_Daily_Inventory`: Daily inventory levels per film per store.

## 4. ETL Process Overview

The ETL script performs the following sequence:

### **Extract (E)**

- Connects to both `sakila` (source) and `rental_film_dw` (target) databases.
- Extracts raw data from relevant `sakila` tables (`staff`, `film`, `store`, `rental`, `payment`, `inventory`) into Pandas DataFrames.

### **Transform (T)**

- **Dimension Population:**
  - `Dim_Date`: Generated programmatically based on the date range of existing transactions.
  - Other Dimensions (`Dim_Staff`, `Dim_Film`, `Dim_Store`, `Dim_Rent`): Directly loaded from source tables.
- **Data Cleaning/Handling:**
  - **Missing Values:** Uses `fillna('')` for string columns (`email`, `description`, `special_features`) and `pd.NaT` for nullable datetime columns (`return_date`).
  - **Surrogate Keys:**
    1.  Dimensions with `AUTO_INCREMENT` keys are loaded first.
    2.  After loading, the generated surrogate keys are queried from the data warehouse and mapped back to their natural keys in Python dictionaries.
    3.  These mappings are then used to replace natural keys with surrogate keys in fact tables.
- **Fact Aggregation:**
  - `Fact_Monthly_Payment`: Aggregates `payment` data by month, staff, and rental to sum `payment_amount` and count `payment_count`.
  - `Fact_Daily_Inventory`: Counts `inventory_id` per `film_id` and `store_id`, then cross-joins with all dates from `Dim_Date` to create daily snapshots.

### **Load (L)**

- Loads the transformed DataFrames into their respective dimension and fact tables in `rental_film_dw` using `pandas.to_sql()`.
- `dropna(inplace=True)` is used on fact tables before loading to drop rows where essential surrogate keys could not be mapped, ensuring referential integrity.

## 5. How to Run

1.  **Prerequisites:** Ensure MySQL is running with `sakila` and `rental_film_dw` databases set up.
2.  **Dependencies:** Install Python libraries:
    ```bash
    pip install pandas SQLAlchemy PyMySQL
    ```
3.  **Database Credentials:** Update MySQL `username`, `password`, `host`, and `port` in the Python scripts if different from `root`/`rootuser`/`127.0.0.1`/`3306`.
4.  **Initial ETL Run:** Execute the main ETL script (provided in previous turns) to populate the data warehouse with clean data.
5.  **Inject Test Data (Optional):** Run the "dirty data" insertion script (provided previously) to add some records with `NULL`s into the `sakila` source database.
6.  **Re-run ETL:** Execute the main ETL script again. Observe how it handles the newly injected data.

## 6. Key Considerations & Future Enhancements

- **Data Integrity:** The ETL enforces referential integrity in the data warehouse through surrogate key mapping and `dropna()` before loading fact tables.
- **Simplifications:** The current ETL assumes a constant inventory level for `Fact_Daily_Inventory` across dates and does not implement advanced Slowly Changing Dimension (SCD) strategies for historical attribute tracking.
